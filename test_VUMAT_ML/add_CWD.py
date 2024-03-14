import sys

def add_CWD(env_path, CWD_directory):
    # Read the file
    with open(env_path, 'r') as file:
        lines = file.readlines()
    print(CWD_directory)
    # Prepare the CWD strings to add
    CWD_include = f'-I{CWD_directory}'
    CWD_library = f'-L{CWD_directory}'

    # Flags to check if CWD is already in the lists
    CWD_include_exists = False
    CWD_library_exists = any(CWD_library in line for line in lines)


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
                if ('ml_module.o' in lines[j] or '-lml_module' in lines[j]) and not CWD_library_exists:
                    # Insert the CWD library statement before 'ml_module.o' and '-lml_module'
                    lines.insert(j, f"    '{CWD_library}',\n")
                    CWD_library_exists = True  # Ensure we don't add it again
                j += 1

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
