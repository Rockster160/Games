# Need to have ssh keys set up correctly to use this properly

from paramiko import SSHClient
import time

host="138.68.3.152"
user="rocco"
script="source /home/rocco/.bashrc && source /home/rocco/.profile && ./deploy_portfolio"

client = SSHClient()
client.load_system_host_keys()
client.connect(host, username=user)
stdin, stdout, stderr = client.exec_command(script)
# Better option here would be to wait for the server to be back up and responding rather than waiting a hardcoded set of time
# The above option would need to also timeout and report an issue
time.sleep(30)
# print("stdout: ", stdout.readlines())
# print("stderr: ", stderr.readlines())
stdin.close()
# Use Ctrl-C to stop
