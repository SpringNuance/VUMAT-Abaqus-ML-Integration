import sys

def add_CWD(env_path, CWD_directory):
    # Read the file
    with open(env_path, 'r') as file:
        lines = file.readlines()
    print(CWD_directory)
    # Prepare the CWD strings to add
    CWD_include = f'-I{CWD_directory}'
    CWD_linking = f'{CWD_directory}/ml_module.o'

    # Flags to check if CWD is already in the lists
    CWD_include_exists = False
    CWD_linking_exists = False


    # Modify the lists if necessary
    for i, line in enumerate(lines):
        if 'compile_fortran = [' in line:
            j = i + 1
            while ']' not in lines[j]:
                if CWD_include in lines[j]:
                    CWD_include_exists = True
                    break
                j += 1
            if not CWD_include_exists:
                lines.insert(j, f"    '{CWD_include}',\n")

        elif 'link_sl = [' in line:
            j = i + 1
            while ']' not in lines[j]:
                if CWD_linking in lines[j]:
                    CWD_linking_exists = True
                    break
                j += 1
            if not CWD_linking_exists:
                lines.insert(j, f"    '{CWD_linking}',\n")

    # Write the modified content back to the file
    with open(env_path, 'w') as file:
        file.writelines(lines)

if __name__ == "__main__":
    # Command-line arguments
    if len(sys.argv) != 3:
        print("Usage: python add_CWD.py <path_to_abaqus_v6.env> <CWD>")
        sys.exit(1)

    env_file_path = sys.argv[1]
    current_working_directory = sys.argv[2]
    
    add_CWD(env_file_path, current_working_directory)
