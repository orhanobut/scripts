from bs4 import BeautifulSoup
import os
import subprocess
from apk_info import ApkInfo
import sys
import os.path

REPORT_PATH = sys.argv[1:][0]


def get_soup(url):
  return BeautifulSoup(open(url), 'html.parser')


def add_header(text):
  file.write("\n\n<h2>" + text + "</h2>\n\n")


def write(text):
  file.write(text)

def generate_pr_info():
  commits = subprocess.Popen(
        'git log @~.. --oneline --no-merges --pretty=%B',
        shell=True,
        stdout=subprocess.PIPE
  ).stdout.read()
  commits = commits.split('\n')

  write('<ul>')
  for commit in commits:
    if commit == '' :
      continue
    write('<li>' + commit + '</li>')
  write('</ul>')

def generate_lint_report():
  soup = get_soup(REPORT_PATH + "/lint.html")
  table = soup.find('table', attrs={'class': 'overview'})

  categories = table.find_all('td', attrs={'class': 'categoryColumn'})
  for category in categories:
    category.a.wrap(soup.new_tag('b'))
    category.a.insert_before(soup.new_tag('hr'))

  # This report is sent via email and it doesn't contain any css/img files, no image will be shown.
  # Therefore remove all images
  img_tags = table.find_all('img')
  for img in img_tags:
    text = img["alt"]
    img.insert_after('[{0}]'.format(str(text)))
    img.extract()

  # Remove links since they point to local address
  a_tags = table.find_all('a')
  for a in a_tags:
    a_content = a.string
    a.insert_after(str(a_content))
    a.extract()

  write(str(table))


def generate_checkstyle_report():
  soup = get_soup(REPORT_PATH + "/checkstyle.html")

  table = soup.find('table', attrs={'class': 'log'})
  table.attrs = None

  write(str(table))


def generate_unit_tests():
  soup = get_soup(REPORT_PATH + "/unittests.html")

  # Add summary
  div_summary = soup.find('div', attrs={'id': 'summary'})
  write(str(div_summary))

  # Tabs are generated dynamically based on the status. For example: If there is no failure test
  # Failure tab won't be shown, therefore we need to dynamically fetch the classes tab which is
  # always the last tab
  tab_links = soup.find('ul', attrs={'class': 'tabLinks'}).find_all('li')
  last_tab = "tab" + str(len(tab_links) - 1)

  # Add test classes
  div_classes = soup.find('div', attrs={'id': last_tab})
  div_classes.h2.extract()

  tr_tags = div_classes.tbody.find_all('tr')
  for tr in tr_tags:
    td_tags = tr.find_all('td')

    # 0 : Empty column, we will replace it with name
    # 1 : Test count
    # 2 : Failure test count
    # 3 : Ignored test count
    # 4 : Duration in second
    # 5 : Status

    for index, item in enumerate(td_tags):
      # There is a bug in the generated report. An empty redundant column is generated.
      # We fix it by removing basically and add the class name as new column
      if index == 0:
        item.extract()

      # If the test class has failures, paint to red
      if index == 2:
        fail_count = float(item.string)
        if fail_count > 0:
          tr['bgcolor'] = "#ff9999"

      # If the test class has ignoring tests, paint to orange
      if index == 3:
        ignore_count = float(item.string)
        if ignore_count > 0:
          tr['bgcolor'] = "#ffeb99"

      # If the duration is longer than 1 second, paint to blue
      if index == 4:
        duration = float(item.string[:-1])
        if duration > 1:
          tr['bgcolor'] = "#ccccff"

  # There is a bug in generated test report html which is class names are not inside <td> tag
  # Remove the links and move them inside a td tag
  links = div_classes.find_all('a')
  for a in links:
    a.wrap(soup.new_tag('td'))
    a.insert_after(str(a.string))
    a.extract()

  write(str(div_classes))


def apk_info_row(current, change, new, remaining):
  return "<td>Current: <b>" + str(current) + "</b></td>" + \
         "<td>Diff: <b>" + str(change) + "</b></td>" + \
         "<td>New: <b>" + str(new) + "</b></td>" + \
         "<td>Remaining: <b>" + str(remaining) + "</b></td>"


def generate_apk_info():
  current_apk_info = ApkInfo.new_info('report/current')
  new_apk_info = ApkInfo.new_info('report/new')

  write("<table>")

  # Method count
  method_count_text = apk_info_row(
      current_apk_info.method_count,
      (new_apk_info.method_count - current_apk_info.method_count),
      new_apk_info.method_count,
      new_apk_info.remaining_method_count()
  )
  write("<tr><td><b>Method Count</b></td><td>" + method_count_text + "</td></tr>")

  # APK Size
  apk_size_text = apk_info_row(
      current_apk_info.apk_size_in_mb_formatted(),
      new_apk_info.apk_size_diff(current_apk_info),
      new_apk_info.apk_size_in_mb_formatted(),
      "-"
  )
  write("<tr><td><b>Apk Size (mb)</b></td><td>" + apk_size_text + "</td></tr>")

  # Min Sdk Version
  min_sdk_version = apk_info_row(current_apk_info.min_sdk_version, "-", new_apk_info.min_sdk_version, "-")
  write("<tr><td><b>Min Sdk Version</b></td><td>" + min_sdk_version + "</td></tr>")

  # Target Sdk Version
  target_sdk_version = apk_info_row(current_apk_info.target_sdk_version, "-", new_apk_info.target_sdk_version, "-")
  write("<tr><td><b>Target Sdk Version</b></td><td>" + target_sdk_version + "</td></tr>")

  # Permissions
  # Check what permission is added
  write("<tr><td><b>Permissions</b></td><td colspan='4'></td></tr>")
  permissions = current_apk_info.permissions_diff(new_apk_info)
  for permission in permissions:
    if permission.deleted:
      write("<tr><td></td><td colspan='4'><font color='red'>[REMOVED] " + permission.name + "</font></td></tr>")
    elif permission.new_added:
      write("<tr><td></td><td colspan='4'><font color='#01dc00'>[NEW] " + permission.name + "</font></td></tr>")
    else:
      write("<tr><td></td><td colspan='4'>" + permission.name + "</td></tr>")
  write("</table>")

def generate_functional_test_results(report_path):
  total_elapsed_time = subprocess.Popen(
    'grep "Time" '+ report_path +' ',
    shell=True,
    stdout=subprocess.PIPE
  ).stdout.read()
  write('<h4>' + total_elapsed_time + '</h4>')

  total_test_count = subprocess.Popen(
    'grep "Tests run" '+ report_path +' ',
    shell=True,
    stdout=subprocess.PIPE
  ).stdout.read()
  write('<h4>' + total_test_count + '</h4>')

  tested_classes = subprocess.Popen(
    'sed -n "s/INSTRUMENTATION_STATUS: class=//gp" '+ report_path +' | uniq',
    shell=True,
    stdout=subprocess.PIPE
  ).stdout.read()
  tested_classes = tested_classes.split('\n')

  write('<ul>')
  for tested_class in tested_classes:
    if tested_class == '' :
      continue
    write('<li>' + tested_class + '</li>')
  write('</ul>')


with open(REPORT_PATH + '/build-report.html', 'w+') as file:
  print "Generating pull request info"
  add_header("Pull Request Info")
  generate_pr_info()

  print "Generating APK info (release)"
  add_header("APK Info (release)")
  generate_apk_info()

  print "Generating lint report"
  add_header("Lint")
  generate_lint_report()

  print "Generating checkstyle report"
  add_header("Checkstyle")
  generate_checkstyle_report()

  print "Generating unit tests"
  add_header("Unit Tests")
  generate_unit_tests()

  functional_tests_path=REPORT_PATH+"/android-test-log.txt"
  if os.path.isfile(functional_tests_path):
    print "Generating functionals tests"
    add_header("Functional Tests")
    generate_functional_test_results(functional_tests_path)

  print "Build report is generated at " + REPORT_PATH + "/build-report.html"
