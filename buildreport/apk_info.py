import os
import subprocess


class ApkInfo:
  method_count = None
  apk_size = None
  permissions = None
  max_count = None
  min_sdk_version = None
  target_sdk_version = None

  def __init__(self, method_count=0, apk_size=0, permissions=None, min_sdk=0, target_sdk=0):
    self.method_count = method_count
    self.apk_size = apk_size
    self.permissions = permissions
    self.max_count = 65536
    self.min_sdk_version = min_sdk
    self.target_sdk_version = target_sdk

  @classmethod
  def new_info(cls, apk_folder_path):

    classes_dex_path = apk_folder_path + '/classes.dex'
    method_count = subprocess.Popen(
        'cat ' + classes_dex_path + ' | head -c 92 | tail -c 4 | hexdump -e \'1/4 "%d\n"\'',
        shell=True,
        stdout=subprocess.PIPE
    ).stdout.read()

    method_count = long(float(method_count))

    apk_path = apk_folder_path + "/app-release.apk"
    # Apk size
    apk_size = os.path.getsize(apk_path)

    # Permissions
    permissions = subprocess.check_output(["aapt", "d", "permissions", apk_path]).split("\n")

    # First item is package name, no need
    del permissions[0]

    # Last item is None, remove it
    del permissions[len(permissions) - 1]

    # Sdk versions
    min_sdk = ApkInfo.sdk_version(apk_path, 'minSdkVersion')
    target_sdk = ApkInfo.sdk_version(apk_path, 'targetSdkVersion')

    return cls(method_count, apk_size, permissions, min_sdk, target_sdk)

  @staticmethod
  def sdk_version(apk_path, name):
    sdk_version = subprocess.Popen(
        'aapt list -a ' + apk_path + ' | grep ' + name,
        shell=True,
        stdout=subprocess.PIPE
    ).stdout.read()

    return int(sdk_version.split('=')[1].split(')')[1], 16)

  def __str__(self):
    return "method_count : " + str(self.method_count) + \
           ", apk_size : " + str(self.apk_size) + \
           ", permissions : " + str(self.permissions)

  def remaining_method_count(self):
    return self.max_count - self.method_count

  def apk_size_in_mb(self):
    return self.apk_size / float(1000 * 1000)

  def apk_size_in_mb_formatted(self):
    return "{:20.4}".format(str(self.apk_size_in_mb()))

  def apk_size_diff(self, info):
    diff = self.apk_size - info.apk_size
    return "{:20.4}".format(str(diff / float(1000 * 1000)))

  def permissions_diff(self, info):
    list = []

    compared_permissions = info.permissions

    for item in self.permissions:
      permission = str(item)
      if permission in compared_permissions:
        list.append(PermissionInfo.no_change(permission))
      else:
        list.append(PermissionInfo.new_added(permission))

    for item in compared_permissions:
      permission = str(item)
      if permission not in self.permissions:
        list.append(PermissionInfo.deleted(permission))

    return list


class PermissionInfo:
  name = None
  deleted = None
  new_added = None

  def __init__(self, name, deleted, new_added):
    self.name = name
    self.deleted = deleted
    self.new_added = new_added

  @classmethod
  def deleted(cls, name):
    return cls(name, False, True)

  @classmethod
  def new_added(cls, name):
    return cls(name, True, False)

  @classmethod
  def no_change(cls, name):
    return cls(name, False, False)
