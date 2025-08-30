# Generate comments for Golang code.
# it searches lines like this:
# func (s *Service) FunctionName(
# func FunctionName(
# type Service struct {
#
# and generate comment like this:
# // FunctionName - <some words depending on function name>
# No AI. Just raw substitution.

import os
import re
import sys

FUNC_PATTERN = re.compile(
    r'^\s*func\s+\(([^)]+)\)\s+(?P<name>[A-Z][A-Za-z0-9_]*)\s*\(', re.MULTILINE
)

FUNC_NO_RECEIVER_PATTERN = re.compile(
    r'^\s*func\s+(?P<name>[A-Z][A-Za-z0-9_]*)\s*\(', re.MULTILINE
)

TYPE_PATTERN = re.compile(
    r'^\s*type\s+(?P<name>[A-Z][A-Za-z0-9_]*)\s+', re.MULTILINE
)

# Common verbs or method prefixes with useful translations
VERB_MAP = {
    "Get": "returns the",
    "Set": "sets the",
    "Is": "checks if it is",
    "Has": "checks if it has",
    "Validate": "validates the",
    "Create": "creates a new",
    "Build": "builds the",
    "List": "lists all",
    "Connect": "establishes a connection to the",
    "Save": "saves the",
    "Load": "loads the",
    "Open": "opens the",
    "Close": "closes the",
    "Run": "runs the",
    "Render": "renders the",
    "Delete": "deletes the",
    "Add": "adds a new",
    "Remove": "removes the",
    "Update": "updates the",
}

# Known acronyms to preserve capitalization
ACRONYMS = {"ID", "URL", "API", "HTTP", "JSON", "IP"}

def normalize_words(words):
    """Fix acronyms like 'I D' -> 'ID' and join words properly."""
    tokens = words.split()
    for i, token in enumerate(tokens):
        upper_token = token.upper()
        if upper_token in ACRONYMS:
            tokens[i] = upper_token
    return ' '.join(tokens)

def split_camel_case(name):
    # Example: GetInstanceID -> ["Get", "Instance", "ID"]
    return re.findall(r'[A-Z](?:[a-z]+|[A-Z]*(?=[A-Z]|$))', name)

def generate_comment(func_name: str) -> str:
    parts = split_camel_case(func_name)
    if not parts:
        return f"// {func_name} - does something."

    verb = parts[0]
    rest = parts[1:]

    # Detect acronyms in rest and normalize them
    rest_words = normalize_words(" ".join(rest)) if rest else ""

    if verb in VERB_MAP:
        action = VERB_MAP[verb]
        if rest_words:
            return f"// {func_name} - {action} {rest_words.lower()}."
        else:
            return f"// {func_name} - {action} value."
    else:
        # fallback: just describe the name
        readable = normalize_words(" ".join(parts)).lower()
        return f"// {func_name} - {readable}."

def process_file(path: str):
    with open(path, 'r') as f:
        lines = f.readlines()

    new_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]

        match_method = FUNC_PATTERN.match(line)
        match_func = FUNC_NO_RECEIVER_PATTERN.match(line)
        match_type = TYPE_PATTERN.match(line)

        func_name = None
        if match_method:
            func_name = match_method.group('name')
        elif match_func:
            func_name = match_func.group('name')
        elif match_type:
            func_name = match_type.group('name')

        if func_name:
            # Check for existing comment
            if i == 0 or not lines[i - 1].strip().startswith('//'):
                comment = generate_comment(func_name)
                new_lines.append(comment + '\n')

        new_lines.append(line)
        i += 1

    with open(path, 'w') as f:
        f.writelines(new_lines)



def walk_go_files(base_dir: str):
    for root, _, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.go') and not file.endswith('_test.go'):
                full_path = os.path.join(root, file)
                process_file(full_path)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python add_godoc_comments.py <directory>")
        sys.exit(1)

    project_path = sys.argv[1]

    if not os.path.isdir(project_path):
        print(f"Error: '{project_path}' is not a directory.")
        sys.exit(1)

    walk_go_files(project_path)
    print(f"Done: Added missing comments in Go files under '{project_path}'")
