import xml.etree.ElementTree as ET
import copy
import os
import shutil

def addConfigToPackage(configPath, baseName):
    package_file = os.path.join(configPath, "Package.pkg")

    # Parse the XML file
    tree = ET.parse(package_file)
    root = tree.getroot()

    # Define the namespace
    namespace_uri = "http://br-automation.co.at/AS/Package"
    ET.register_namespace('', namespace_uri)  # Register the namespace without a prefix

    # Define the namespace dictionary for searching
    namespace = {"ns": namespace_uri}

    # Find the <Objects> section
    objects_section = root.find(".//ns:Objects", namespace)
    if objects_section is None:
        print("Objects section not found in the package file.")
        return

    # Create a new <Object> element
    new_object = ET.Element("Object", {"Type": "Package"})
    new_object.text = baseName

    # Add the new <Object> element to the <Objects> section
    objects_section.append(new_object)

    # Save the updated XML back to the file
    with open(package_file, "wb") as f:
        tree.write(f, encoding="utf-8", xml_declaration=True)
    print(f"Added entry for '{baseName}' to the package file.")

def updatePackageFile(configPath, baseName):
    # Define the path to the Package.pkg file
    package_file = os.path.join(configPath, "Package.pkg")

    # Parse the XML file
    tree = ET.parse(package_file)
    root = tree.getroot()

    # Define the namespace
    namespace_uri = "http://br-automation.co.at/AS/Package"
    ET.register_namespace('', namespace_uri)  # Register the namespace without a prefix

    # Define the namespace dictionary for searching
    namespace = {"ns": namespace_uri}

    # Find the <Objects> section
    objects_section = root.find(".//ns:Objects", namespace)
    if objects_section is None:
        print("Objects section not found in the package file.")
        return

    # Update all <Object> entries by adding the prefix baseName_
    for obj in objects_section.findall("ns:Object", namespace):
        if obj.text:
            file_number = int(obj.text.split('_')[-1].split('.')[0])
            file_ending = os.path.splitext(obj.text)[1]
            obj.text = f"{baseName}{file_number}{file_ending}"

    # Save the updated XML back to the file
    with open(package_file, "wb") as f:
        tree.write(f, encoding="utf-8", xml_declaration=True)
    print(f"Updated all object entries in '{package_file}' with prefix '{baseName}_'.")


def copy_config(configPath, rootName, copyName, numFile):
    # Find the folder to copy
    source_folder = None
    for folder in os.listdir(configPath):
        if folder.endswith(rootName):
            source_folder = os.path.join(configPath, folder)
            break

    if not source_folder or not os.path.isdir(source_folder):
        print(f"Source folder ending with '{rootName}' not found.")
        return

    # Create the destination folder
    # Extract the last folder name from the source folder path
    last_folder_name = os.path.basename(source_folder)
    destination_folder = os.path.join(configPath, last_folder_name.replace(rootName, copyName))
    shutil.copytree(source_folder, destination_folder)
    print(f"Copied folder '{source_folder}' to '{destination_folder}'.")

    # Rename all files in the copied folder
    nameConfig = f"Rob{numFile}_"
    for root, _, files in os.walk(destination_folder):
        for file in files:
            if file == "Package.pkg":
                updatePackageFile(destination_folder, nameConfig)
                continue
            old_file_path = os.path.join(root, file)
            file_number = int(file.split('_')[-1].split('.')[0])
            file_ending = os.path.splitext(file)[1]
            new_file_name = f"{nameConfig}{file_number}{file_ending}"
            new_file_path = os.path.join(root, new_file_name)
            os.rename(old_file_path, new_file_path)
            print(f"Renamed file '{old_file_path}' to '{new_file_path}'.")

    # Replace occurrences of rootFolder with copyFolder in all files
    for root, _, files in os.walk(destination_folder):
        for file in files:
            file_path = os.path.join(root, file)
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()

            updated_content = content.replace(rootName, copyName)

            with open(file_path, "w", encoding="utf-8") as f:
                f.write(updated_content)
            print(f"Updated references in file '{file_path}'.")
    
    addConfigToPackage(configPath, os.path.basename(destination_folder))


def deep_copy_element(element):
    return copy.deepcopy(element)

def edit_hardware(file_path, module_name, new_module_name):
    # Parse the XML file
    tree = ET.parse(file_path)
    root = tree.getroot()

    # Define the namespace
    namespace_uri = "http://br-automation.co.at/AS/Hardware"
    ET.register_namespace('', namespace_uri)  # Register the namespace without a prefix

    # Define the namespace dictionary for searching
    namespace = {"ns": namespace_uri}

    # Find the start and end modules
    start_module = None
    end_module = None
    for module in root.findall(".//ns:Module", namespace):
        if "Name" in module.attrib:
            if start_module is None and module.attrib["Name"].endswith(module_name):
                start_module = module
            if module.attrib["Name"].endswith(module_name):
                end_module = module

    if start_module is None or end_module is None:
        print("Start or end module not found.")
        return

    # Get the index of the start module
    start_index = list(root).index(start_module)
    end_index = list(root).index(end_module)

    # Extract the modules to copy
    modules_to_copy = list(root)[start_index:end_index + 1]

    # Insert the copies and increment NodeNumber
    for module in modules_to_copy:
        new_module = ET.Element(module.tag, module.attrib)
        # Increment the NodeNumber attribute
        if "NodeNumber" in new_module.attrib:
            del new_module.attrib["NodeNumber"]

        if "Name" in new_module.attrib:
            if new_module.attrib["Name"].endswith(module_name):
                new_module.attrib["Name"] = new_module.attrib["Name"].replace(module_name, new_module_name)
                
        for child in module:

            childNew = deep_copy_element(child)
            if "Connection" in childNew.tag and "Type" in new_module.attrib and new_module.attrib["Type"] != "MotorSynchronous_any":
                continue;
            else:
                if "TargetModule" in childNew.attrib:
                    childNew.attrib["TargetModule"] = childNew.attrib["TargetModule"].replace(module_name, new_module_name)
            
            if "Parameter" in childNew.tag:
                if "Value" in childNew.attrib:
                    childNew.attrib["Value"] = childNew.attrib["Value"].replace(module_name, new_module_name)
            
            new_module.append(childNew)
        root.insert(end_index + 1, new_module)

    # Write the modified XML back to the file
    with open(file_path, "wb") as f:
        tree.write(f, encoding="us-ascii", xml_declaration=True)
    print(f"copy inserted successfully.")

def copyTaskConfig(tasks_path, base_task, new_task, robotNameOld, robotNameNew):
    fromFolder = os.path.join(tasks_path, base_task)
    configFolder = os.path.join(tasks_path, new_task)
    # Create the new folder for the task configuration
    if not os.path.exists(configFolder):
        os.makedirs(configFolder)
        print(f"Created new folder: {configFolder}")
    else:
        print(f"Folder already exists: {configFolder}")

    # Copy the DefineLinks.st file from the base task folder to the new task folder
    define_links_file = "DefineLinks.st"
    source_file = os.path.join(fromFolder, define_links_file)
    destination_file = os.path.join(configFolder, define_links_file)

    if os.path.exists(source_file):
        shutil.copy(source_file, destination_file)
        print(f"Copied '{define_links_file}' from '{fromFolder}' to '{configFolder}'.")
    else:
        print(f"'{define_links_file}' not found in '{fromFolder}'.")

    with open(destination_file, "r", encoding="utf-8") as f:
        content = f.read()
        updated_content = content.replace(robotNameOld, robotNameNew)

    with open(destination_file, "w", encoding="utf-8") as f:
        f.write(updated_content)
        print(f"Updated references in file '{destination_file}'.")

    # Define the path to the tasks file
    ice_file = os.path.join(fromFolder, "IEC.prg")
    tree = ET.parse(ice_file)
    root = tree.getroot()
    namespace_uri = "http://br-automation.co.at/AS/Program"
    ET.register_namespace('', namespace_uri)  # Register the namespace without a prefix
    namespace = {"ns": namespace_uri}

    # Find the <Tasks> section
    files_section = root.find(".//ns:Files", namespace)
    if files_section is None:
        print("Tasks section not found in the tasks file.")
        return
    
    # Iterate over all <File> elements and add the Reference="true" attribute
    for file_element in files_section.findall("ns:File", namespace):
        if file_element.text == "DefineLinks.st":
            continue

        file_element.set("Reference", "true")
        file_element.text = "\\Logical\\Robots\\" + base_task + "\\" + file_element.text

    # Save the updated XML back to the file
    with open(os.path.join(configFolder, "IEC.prg"), "wb") as f:
        tree.write(f, encoding="utf-8", xml_declaration=True)
    print(f"Added entry for '{new_task}' to the package file.")



def add_task(tasks_path, base_task, new_task, robotNameOld, robotNameNew):
    # Define the path to the tasks file
    tasks_file = os.path.join(tasks_path, "Package.pkg")

    # Parse the XML file
    tree = ET.parse(tasks_file)
    root = tree.getroot()

    # Define the namespace
    namespace_uri = "http://br-automation.co.at/AS/Package"
    ET.register_namespace('', namespace_uri)  # Register the namespace without a prefix

    # Define the namespace dictionary for searching
    namespace = {"ns": namespace_uri}

    # Find the <Tasks> section
    tasks_section = root.find(".//ns:Objects", namespace)
    if tasks_section is None:
        print("Tasks section not found in the tasks file.")
        return

    # Create a new <Task> element
    new_object = ET.Element("Object", {"Type": "Program", "Language": "IEC"})
    new_object.text = new_task

    # Add the new <Object> element to the <Objects> section
    tasks_section.append(new_object)

    # Save the updated XML back to the file
    with open(tasks_file, "wb") as f:
        tree.write(f, encoding="utf-8", xml_declaration=True)
    print(f"Added entry for '{new_task}' to the package file.")

    copyTaskConfig(tasks_path, base_task, new_task, robotNameOld, robotNameNew)


def addRobotToObjectHierarchy(objectHierachy, moduleName, xTranslation=0):
    # Parse the XML file
    tree = ET.parse(objectHierachy)
    root = tree.getroot()

    global_coordinate_system = root.find(".//Group[@ID='GlobalCoordinateSystem']")
    if global_coordinate_system is None:
        print("GlobalCoordinateSystem section not found in the hierarchy file.")
        return
    
    max_object_number = 0
    for group in global_coordinate_system.findall("Group"):
        group_id = group.attrib.get("ID", "")
        if group_id.startswith("Object[") and group_id.endswith("]"):
            try:
                number = int(group_id[7:-1])  # Extract the number inside "Object[number]"
                max_object_number = max(max_object_number, number)
            except ValueError:
                continue

    # Create a new <Group> element
    new_group = ET.Element("Group", {"ID": f"Object[{max_object_number+1}]"})
    selector = ET.SubElement(new_group, "Selector", {"ID": "Type"})
    ET.SubElement(selector, "Property", {"ID": "AxesGroupRef", "Value": f"gAxesGroup_{moduleName}"})
    translation_group = ET.SubElement(selector, "Group", {"ID": "Translation"})
    ET.SubElement(translation_group, "Property", {"ID": "X", "Value": str(xTranslation)})

    global_coordinate_system.append(new_group)

    with open(objectHierachy, "wb") as f:
        tree.write(f, encoding="utf-8", xml_declaration=True)
    print(f"Added new group for '{moduleName}' to the GlobalCoordinateSystem section.")


# Ask the user for the number of copies
#num_copies = int(input("Enter the number of copies to insert: "))
num_copies = 15
physical_config = "Config1"
plc_name = "5APC3100_KBU3_000"

# Example usage
base_dir = os.path.dirname(os.path.abspath(__file__))
file_path = os.path.join(base_dir, "Physical", physical_config, "Hardware.hw")
configPath = os.path.join(base_dir, "Physical", physical_config, plc_name, "mappMotion")
tasks = os.path.join(base_dir, "Logical", "Robots")
objectHierachy = os.path.join(base_dir, "Physical", physical_config, plc_name, "mappMotion", "Hierarchy.objecthierarchy")

module_name = "D4r1100R"
baseTask = "APP_Robot1"

for i in range(num_copies):
    new_module_name = f"{module_name}_{i + 2}"  # Generate new module name based on loop index
    edit_hardware(file_path, f"{module_name}_{1}", new_module_name)
    copy_config(configPath, f"{module_name}_{1}", new_module_name,  f"{i + 2}")
    add_task(tasks, baseTask, f"APP_Robot{i + 2}", f"{module_name}_{1}", new_module_name)
    addRobotToObjectHierarchy(objectHierachy, new_module_name,  1100*(i+1))
    print(f"Copy {i + 1} of {num_copies} completed with new module name: {new_module_name}")

