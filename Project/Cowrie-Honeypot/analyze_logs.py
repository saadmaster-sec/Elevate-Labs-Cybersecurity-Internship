import json
from collections import Counter

log_file = "var/log/cowrie/cowrie.json"

connections = 0
successful_logins = 0
failed_logins = 0

usernames = Counter()
passwords = Counter()
commands = Counter()
source_ips = Counter()

with open(log_file, "r") as file:
    for line in file:
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue

        eventid = event.get("eventid", "")

        if eventid == "cowrie.session.connect":
            connections += 1
            src_ip = event.get("src_ip")
            if src_ip:
                source_ips[src_ip] += 1

        elif eventid == "cowrie.login.success":
            successful_logins += 1

            username = event.get("username")
            password = event.get("password")

            if username:
                usernames[username] += 1

            if password:
                passwords[password] += 1

        elif eventid == "cowrie.login.failed":
            failed_logins += 1

            username = event.get("username")
            password = event.get("password")

            if username:
                usernames[username] += 1

            if password:
                passwords[password] += 1

        elif eventid == "cowrie.command.input":
            command = event.get("input")

            if command:
                commands[command] += 1


print("=" * 50)
print("         COWRIE HONEYPOT LOG ANALYSIS")
print("=" * 50)

print(f"\nTotal Connections: {connections}")
print(f"Successful Logins: {successful_logins}")
print(f"Failed Logins: {failed_logins}")

print("\nTop Source IPs:")
for ip, count in source_ips.most_common():
    print(f"{ip}: {count}")

print("\nUsernames Attempted:")
for username, count in usernames.most_common():
    print(f"{username}: {count}")

print("\nPasswords Attempted:")
for password, count in passwords.most_common():
    print(f"{password}: {count}")

print("\nCommands Observed:")
for command, count in commands.most_common():
    print(f"{command}: {count}")

print("\n" + "=" * 50)
print("Analysis Complete")
print("=" * 50)
