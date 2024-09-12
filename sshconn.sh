#!/bin/bash

# Define the connections file path
connections_file="$HOME/.connections"

# Function to show help documentation
show_help() {
  echo "Usage: sshconn [options]

Options:
  --list                 List all connections with numbered options
  --by-server            Group connections by IP address and prompt for selection
  --add                  Add a new connection entry (domain, user, IP)
  -h, --help             Show this help documentation
  [domain]               Enter a domain name directly to connect to it

Operations:
  1. Use --list to display all available connections, sorted by domain name.
  2. Use --by-server to list connections grouped by IP addresses. You can then choose a specific connection to manage.
  3. Use --add to add a new connection (domain, username, IP) to the ~/.connections file.
  4. If you enter a domain directly, the script will attempt to connect to that server via SSH.
  5. After selecting a connection, you can choose to connect (y), edit (edit), or delete (del) the connection.
"
}

# Function to list all domains with numbers, sorted alphabetically by domain
list_domains() {
  echo "Available connections:"
  awk -F',' '{print $1}' "$connections_file" | sort | nl -w1 -s". " | column -c $(tput cols)
}

# Function to add a new entry to the connections file
add_entry() {
  read -p "Enter domain: " domain
  read -p "Enter username: " username
  read -p "Enter IP address: " ip_address

  if grep -q "^$domain," "$connections_file"; then
    echo "ERROR: Domain $domain already exists."
    exit 1
  fi

  echo "$domain,$username,$ip_address" >> "$connections_file"
  echo "New entry added: $domain,$username,$ip_address"
}

# Function to list connections grouped by IP address, sorted alphabetically within each IP group
list_by_server() {
  echo "Connections grouped by IP:"
  awk -F',' '{ print $3,$1,$2 }' "$connections_file" | sort -t' ' -k1,1 -k2,2 | nl -w1 -s". " | column -t

  read -p "Select a number to proceed: " selection_number

  selected_line=$(awk -F',' '{ print $3,$1,$2 }' "$connections_file" | sort -t' ' -k1,1 -k2,2 | nl -w1 -s". " | awk "NR==$selection_number")

  if [ -z "$selected_line" ]; then
    echo "ERROR: Invalid selection."
    exit 1
  fi

  ip_address=$(echo "$selected_line" | awk '{print $2}')
  domain=$(echo "$selected_line" | awk '{print $3}')
  username=$(echo "$selected_line" | awk '{print $4}')

  read -p "You've selected $domain. Would you like to connect (y), edit (edit), or delete (del)? [y/edit/del] " action

  case "$action" in
    y)
      ssh "$username@$ip_address"
      ;;
    edit)
      echo "Editing $domain:"
      read -p "Enter new domain (or press Enter to keep \"$domain\"): " new_domain
      read -p "Enter new username (or press Enter to keep \"$username\"): " new_username

      new_domain=${new_domain:-$domain}
      new_username=${new_username:-$username}

      sed -i '' "s|^$domain,$username,$ip_address|$new_domain,$new_username,$ip_address|" "$connections_file"
      echo "Entry updated."
      ;;
    del)
      echo "Deleting $domain..."
      sed -i '' "/^$domain,$username,$ip_address/d" "$connections_file"
      echo "$domain has been deleted."
      ;;
    *)
      echo "Invalid option. Exiting."
      exit 1
      ;;
  esac
}

# Check if the connections file exists
if [ ! -f "$connections_file" ]; then
  echo "ERROR: No ~/.connections file found."
  exit 1
fi

# Check for help or no arguments provided
if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ -z "$1" ]; then
  show_help
  exit 0
fi

# Check if the script was run with the --list option
if [ "$1" == "--list" ]; then
  list_domains

  read -p "Enter the number corresponding to the domain: " domain_number

  if ! [[ "$domain_number" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Invalid input. Please enter a number."
    exit 1
  fi

  chosen_domain=$(awk -F',' '{print $1}' "$connections_file" | sort | awk "NR==$domain_number")

  if [ -z "$chosen_domain" ]; then
    echo "ERROR: No domain found for number $domain_number."
    exit 1
  fi

  $0 "$chosen_domain"
  exit 0
fi

# Check if the script was run with the --add option
if [ "$1" == "--add" ]; then
  add_entry
  exit 0
fi

# Check if the script was run with the --by-server option
if [ "$1" == "--by-server" ]; then
  list_by_server
  exit 0
fi

# Regular domain handling flow
domain_input=$1

if [ -z "$domain_input" ]; then
  echo "ERROR: Please provide a domain as input or use the --list option."
  exit 1
fi

matches=$(grep "^$domain_input," "$connections_file")

match_count=$(echo "$matches" | wc -l)

if [ "$match_count" -eq 0 ]; then
  echo "No connection found for $domain_input."
  exit 0
elif [ "$match_count" -gt 1 ]; then
  echo "ERROR: Multiple entries for $domain_input. Please edit your ~/.connections file to have only one line for this domain."
  exit 1
else
  user=$(echo "$matches" | cut -d',' -f2)
  ip_address=$(echo "$matches" | cut -d',' -f3)

  # Directly execute the SSH command
  ssh "$user@$ip_address"
fi
