def historyExecution(number_of_sessions_ago=1):
    commands = """
import sys
import os  # The module you want to import
import tempfile

ipython = get_ipython()

# Your startup script here
config_dir = ipython.ipython_dir

# Create a temporary file in the specified directory
fd, temp_name = tempfile.mkstemp(dir=config_dir)
os.close(fd)
os.remove(temp_name)
temp_name = temp_name + '.py'

# ipython magic line function to store command history into temp_name file
ipython.run_line_magic('history', f'-f {temp_name} ~{number_of_sessions_ago}/')

# directory to special vim config
start_up_dir = os.path.join(config_dir, 'profile_default/startup/python_startup.vim')
with open(temp_name, 'a') as fh:
    fh.write(f'''

# execute above command from {number_of_sessions_ago} sessions ago
# In Normal Mode:
#    q/quit, Enter/confirm''')

# open special vim command edit panel
system_return_value = os.system(f'vim -u "{start_up_dir}" "{temp_name}"')

if system_return_value == 0:
    with open(temp_name) as fh:
        commands = fh.read()
        print(commands)
        print()
        confirmation = input('press y/Y to execute: ')
        if confirmation in ['y', 'Y']:
            # exec(commands)
            # this will cause error: `ERROR! Session/line number was not unique in database. History logging moved to new session nnn`
            # ipython.history_manager.store_inputs(ipython.execution_count, commands)
            ipython.run_cell(commands)

# Remember to delete the temporary file when you're done with it
os.remove(temp_name)

# Remove the module from sys.modules
del sys.modules['os']
del sys.modules['tempfile']"""

    parameter_inserted_commands = commands.replace('number_of_sessions_ago', str(number_of_sessions_ago))
    return parameter_inserted_commands


if __name__ == '__main__':
    exec(historyExecution(number_of_sessions_ago=1))
