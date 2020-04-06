import json
import os
import glob
import shutil

FILE_NOT_FOUND_ERROR = 1
KEY_ERROR = 2


def file_not_found_error(e, filename):
    print(f"File '{e.filename}' was not found")
    exit(FILE_NOT_FOUND_ERROR)


def key_error(e, filename):
    print(f"'{filename}' does not have key '{e.args[0]}'")
    exit(KEY_ERROR)


verbose = False


def _log(*args):
    print(*args)


def _log_stub(*args):
    pass


log = _log if verbose else _log_stub


def main():
    name, version = get_name_and_version()
    directory_name = f"{name}_{version}"
    include_list, exclude_list, export_base, mods_base = load_export_files()
    export_directory = f"{export_base}{directory_name}/"
    mods_directory = f"{mods_base}{directory_name}/"
    create_directory(export_directory)
    create_directory(mods_directory)

    mod_files = get_files(include_list=include_list, exclude_list=exclude_list)
    update_mod_files(export_directory=export_directory,
                     mods_directory=mods_directory, file_list=mod_files)

    remove_extra_files(change_directory=export_directory,
                       exclude_list=exclude_list)
    remove_extra_files(change_directory=mods_directory,
                       exclude_list=exclude_list)

    create_zip(destination=export_directory,
               directory_name=directory_name)


def get_name_and_version():
    filename = "./info.json"
    try:
        with open(filename, "r") as file:
            obj = json.load(file)
            return obj["name"], obj["version"]
    except FileNotFoundError as e:
        file_not_found_error(e, filename)
    except KeyError as e:
        key_error(e, filename)


def create_directory(directory):
    directories = directory.split("/")
    for i in range(1, len(directories)):
        name = "/".join(directories[0:i])
        if not os.path.exists(name):
            log(f"creating directory \"{name}\"")
            os.mkdir(name)


def load_export_files():
    filename = "./export_files.json"
    try:
        with open(filename, "r") as file:
            obj = json.load(file)
            return obj["include"], obj["exclude"], obj["export_directory"], obj["mods_directory"]
    except FileNotFoundError as e:
        file_not_found_error(e, filename)
    except KeyError as e:
        key_error(e, filename)


def get_files(include_list, exclude_list, base_dir="./"):
    for i in include_list:
        name = f"{base_dir}{i}"
        for filename in glob.iglob(name, recursive=True):
            filename = "/".join(filename.split("\\"))
            for exclude in exclude_list:
                for ex in glob.iglob(f"{base_dir}{exclude}", recursive="true"):
                    ex = "/".join(ex.split("\\"))
                    if filename == ex or ex.endswith("/") and filename.startswith(ex):
                        break
                else:
                    continue
                break
            else:
                yield filename


def update_mod_files(export_directory, mods_directory, file_list):
    for file in file_list:
        export_file = f"{export_directory}{file}"
        mods_file = f"{mods_directory}{file}"
        create_directory(export_file)
        create_directory(mods_file)
        update_file(file, export_file)
        update_file(file, mods_file)


def update_file(src, dest):
    if os.path.exists(dest):
        if os.path.getmtime(src) == os.path.getmtime(dest):
            log(f"skipping \"{dest}\"")
        else:
            log(f"updating \"{dest}\"")
            shutil.copy2(src, dest)
    else:
        log(f"adding \"{dest}\"")
        shutil.copy2(src, dest)


def remove_extra_files(change_directory, exclude_list, check_directory="./"):
    file_list = get_files(include_list=["**/*"],
                          exclude_list=exclude_list, base_dir=change_directory)
    for file in file_list:
        rel_file = file[len(change_directory):]
        export_file = f"{check_directory}{rel_file}"
        if not os.path.exists(export_file):
            log(f"removing \"{file}\"")
            os.remove(file)
            rel_folders = rel_file.split("/")[:-1]
            folders = (f'{change_directory}{"/".join(rel_folders[0:i])}'
                       for i in range(len(rel_folders), -1, -1))
            for folder in folders:
                if os.path.exists(folder) and os.path.isdir(folder) and not os.listdir(folder):
                    log(f"removing \"{folder}\"")
                    os.rmdir(folder)


def create_zip(destination, directory_name):
    return shutil.make_archive(destination, "zip", "exports/", directory_name)


if __name__ == "__main__":
    main()
