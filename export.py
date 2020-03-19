import json
import os
import glob
import shutil

verbose = False


def main():
    name, version = get_name_and_version()
    dir_name = f"{name}_{version}"
    export_folder = f"./exports/{dir_name}/"
    mods_folder = f"C:/Users/triav/AppData/Roaming/Factorio/mods/{dir_name}/"
    # TODO rename directory, instead of create a new one, if one exists with
    # a lower version number
    create_directory(export_folder)
    create_directory(mods_folder)
    export_list = [
        "**/*.png",
        "**/*.lua",
        "locale/**/*.cfg",
        "changelog.txt",
        "**/*.json"
    ]
    mod_files = get_files(export_list)
    update_mod_files(export_folder, mods_folder, mod_files)
    remove_extra_files(export_folder, mods_folder, export_list)
    create_zip(export_folder, dir_name)


def get_name_and_version():
    filename = "./info.json"
    try:
        with open(filename, "r") as file:
            obj = json.load(file)
            return obj["name"], obj["version"]
    except FileNotFoundError as file_error:
        print(f"File was not found: {file_error.filename}")
        exit(1)
    except KeyError as key_error:
        print(f"'{filename}' does not have key '{key_error.args[0]}'")
        exit(2)


def create_directory(directory):
    directories = directory.split("/")
    for i in range(1, len(directories)):
        name = "/".join(directories[0:i])
        if not os.path.exists(name):
            if verbose:
                print(f"creating directory \"{name}\"")
            os.mkdir(name)


def get_files(file_list, base_dir="./"):
    for i in file_list:
        name = f"{base_dir}{i}"
        for filename in glob.iglob(name, recursive=True):
            filename = "/".join(filename.split("\\"))
            if filename.startswith("./exports/"):
                continue
            yield filename


def update_mod_files(export_folder, mods_folder, files):
    for file in files:
        export_file = f"{export_folder}{file}"
        mods_file = f"{mods_folder}{file}"
        create_directory(export_file)
        create_directory(mods_file)
        update_file(file, export_file)
        update_file(file, mods_file)


def update_file(src, dest):
    if os.path.exists(dest):
        if os.path.getmtime(src) == os.path.getmtime(dest):
            if verbose:
                print(f"skipping \"{dest}\"")
        else:
            if verbose:
                print(f"updating \"{dest}\"")
            shutil.copy2(src, dest)
    else:
        if verbose:
            print(f"adding \"{dest}\"")
        shutil.copy2(src, dest)


def remove_extra_files(export_folder, mods_folder, export_list):
    file_list = get_files(export_list, mods_folder)
    for file in file_list:
        rel_file = file[len(mods_folder):]
        export_file = f"{export_folder}{rel_file}"
        if not os.path.exists(export_file):
            if verbose:
                print(f"removing \"{file}\"")
            os.remove(file)
            rel_folders = rel_file.split("/")[:-1]
            folders = (f'{mods_folder}{"/".join(rel_folders[0:i])}'
                       for i in range(len(rel_folders), -1, -1))
            for folder in folders:
                if os.path.exists(folder) and os.path.isdir(folder) and not os.listdir(folder):
                    if verbose:
                        print(f"removing \"{folder}\"")
                    os.rmdir(folder)


def create_zip(dest, dir_name):
    return shutil.make_archive(dest, "zip", "exports/", dir_name)


if __name__ == "__main__":
    main()
