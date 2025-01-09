import os

def add_header_to_go_files(directory, header):
    """
    Add a header to all .go files in the given directory and its subdirectories.

    :param directory: The root directory to start searching.
    :param header: The header string to add to each file.
    """
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".go"):
                file_path = os.path.join(root, file)
                with open(file_path, "r+") as f:
                    content = f.read()
                    # Check if the header is already present
                    if not content.startswith(header):
                        f.seek(0)
                        f.write(header + "\n\n" + content)
                        print(f"Header added to: {file_path}")
                    else:
                        print(f"Header already present in: {file_path}")

if __name__ == "__main__":
    header = "// Copyright © 2024 Company name https://companyname.com. All rights reserved."
    current_directory = os.getcwd()
    add_header_to_go_files(current_directory, header)
