# Function to autocomplete domain names for the sshconn command
_sshconn_completions() {
  # Get the input so far (partial domain name)
  local cur_word="${COMP_WORDS[COMP_CWORD]}"

  # Path to the connections file
  local connections_file="$HOME/.connections"

  # Make sure the connections file exists
  if [[ ! -f "$connections_file" ]]; then
    return 0
  fi

  # Fetch all the domain names from the connections file
  local domains=$(awk -F',' '{print $1}' "$connections_file")

  # Filter domains based on the input so far (partial domain name)
  COMPREPLY=($(compgen -W "$domains" -- "$cur_word"))
}

# Register the completion function for sshconn
complete -F _sshconn_completions sshconn
