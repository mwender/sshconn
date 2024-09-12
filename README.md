# SSHConn

`SSHConn` is a Bash script that simplifies the management of SSH connections. It allows you to store, list, and manage SSH connections based on domain, username, and IP address. You can also group connections by server, add new connections, and perform SSH connections directly by specifying a domain.

## Features

- **List Connections**: Display a numbered list of stored SSH connections.
- **Group by Server**: View connections grouped by their IP address.
- **Add New Connections**: Easily add new SSH connection entries.
- **Connect Automatically**: Run `sshconn [domain]` to automatically SSH into a server.
- **Edit or Delete**: Edit or delete existing connections.
- **Help Menu**: A built-in help menu to display usage instructions.

## Installation

You can easily install the `sshconn` script using `curl` or `wget` by following the instructions below:

### Option 1: Install via Curl

```bash
# Download the script
curl -L https://raw.githubusercontent.com/mwender/sshconn/main/sshconn.sh -o /usr/local/bin/sshconn

# Make the script executable
chmod +x /usr/local/bin/sshconn
```

### Option 2: Install via Wget

```bash
# Download the script
wget https://raw.githubusercontent.com/mwender/sshconn/main/sshconn.sh -O /usr/local/bin/sshconn

# Make the script executable
chmod +x /usr/local/bin/sshconn
```

Once installed, you can start using the script by running:

```bash
sshconn -h
```

This will display the help menu with available options.

## Usage

- **List all connections**:
  ```bash
  sshconn --list
  ```

- **Group connections by IP**:
  ```bash
  sshconn --by-server
  ```

- **Add a new connection**:
  ```bash
  sshconn --add
  ```

- **Connect to a domain**:
  ```bash
  sshconn [domain]
  ```

## Changelog

_1.0.0_

- First release.

## License

This project is licensed under the MIT License.
