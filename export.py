import json
import os
import glob
import shutil


def main():
    name, version = get_name_and_version()
    dir_name = f"{name}_{version}"
    create_export_directory(dir_name)
    files = [
        "changelog.txt",
        "**/*.json",
        "**/*.lua",
        "**/*.png",
        "locale/**/*.cfg"
    ]
    add_content(dir_name, files)
    zip_file = create_zip(dir_name)
    copy_to_mods(f"exports/{dir_name}",
                 f"C:/Users/triav/AppData/Roaming/Factorio/mods/{dir_name}")


def get_name_and_version():
    with open("./info.json", "r") as file:
        obj = json.load(file)
        return obj["name"], obj["version"]


def create_export_directory(name):
    if not os.path.exists("exports"):
        os.mkdir("exports")
    if not os.path.exists(f"exports/{name}"):
        os.mkdir(f"exports/{name}")


def create_zip(name):
    zip_name = f"exports/{name}"
    return shutil.make_archive(zip_name, "zip", f"exports/", name)


def add_content(dir_name, files):
    for i in files:
        for filename in glob.iglob(i, recursive=True):
            filename = "/".join(filename.split("\\"))
            if filename.startswith("exports/"):
                continue
            directories = filename.split("/")
            for i in range(1, len(directories)):
                name = f'exports/{dir_name}/{"/".join(directories[0:i])}'
                if not os.path.exists(name):
                    os.mkdir(name)
            shutil.copy2(filename, f"exports/{dir_name}/{filename}")


def copy_to_mods(src, dst):
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(src, dst, )


if __name__ == "__main__":
    main()
