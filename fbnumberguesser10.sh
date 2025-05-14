#!/bin/bash

# Function to print a styled header (basic colors)
print_header() {
    echo -e "\033[1;34m--------------------------------------------------\033[0m"
    echo -e "\033[1;34m    Bash Phone Number Combination Generator     \033[0m"
    echo -e "\033[1;34m            (Tool assumes that the       \033[0m"
    echo -e "\033[1;34m    middle 5 digits not starting with 0 or 1)   \033[0m"
    echo -e "\033[1;34m--------------------------------------------------\033[0m"
    echo -e "\033[3mThis tool generates 10-digit phone number combinations.\033[0m\n"
}

# Function to validate digit input
validate_digits() {
    local input=$1
    local length=$2
    if [[ ! "$input" =~ ^[0-9]+$ ]]; then
        echo "Error: Input must contain only digits."
        return 1
    fi
    if [ ${#input} -ne "$length" ]; then
        echo "Error: Input must be exactly $length digits long."
        return 1
    fi
    return 0
}

print_header

# Get first three digits
while true; do
    read -p "Enter the first 3 known digits: " first_three_digits
    if validate_digits "$first_three_digits" 3; then
        break
    else
        echo -e "\033[31mInvalid input. Please try again.\033[0m"
    fi
done

# Get last two digits
while true; do
    read -p "Enter the last 2 known digits: " last_two_digits
    if validate_digits "$last_two_digits" 2; then
        break
    else
        echo -e "\033[31mInvalid input. Please try again.\033[0m"
    fi
done

echo -e "\n\033[1mInputs received:\033[0m Prefix: \033[36m$first_three_digits\033[0m, Suffix: \033[36m$last_two_digits\033[0m"
echo -e "\033[1mConstraint:\033[0m The 5 middle digits will not start with '0' or '1'.\n"

# Total combinations: 8 (for first digit of middle part) * 10^4 (for the other 4) = 80,000
total_combinations=80000

# Ask for output choice
echo "How would you like to output the combinations?"
select output_choice in "Print to console" "Save to a file" "Cancel"; do
    case $output_choice in
        "Print to console" )
            echo -e "\nGenerating and printing $total_combinations numbers for: \033[36m${first_three_digits}\033[0m[2-9]XXXX\033[36m${last_two_digits}\033[0m"
            echo "This will print $total_combinations lines. Proceed?"
            read -p "(y/n): " confirm_print
            # Convert to lowercase for case-insensitive comparison
            confirm_print_lower=$(echo "$confirm_print" | tr '[:upper:]' '[:lower:]')
            if [[ "$confirm_print_lower" != "y" && "$confirm_print_lower" != "yes" ]]; then # Accept 'y' or 'yes'
                echo "Operation cancelled."
                exit 0
            fi

            count=0
            echo "Starting generation (Progress: one '.' per 1000 numbers):"
            # Loop for the 5 middle digits, starting from 20000 up to 99999
            for i in $(seq 20000 99999); do
                middle_five_digits=$(printf "%05d" "$i") # Ensures 5 digits, e.g., 20000
                echo "${first_three_digits}${middle_five_digits}${last_two_digits}"
                count=$((count + 1))
                if (( count % 1000 == 0 )); then
                    echo -n "." # Simple progress indicator
                fi
            done
            echo -e "\n\033[1;32mGeneration complete. Printed $count combinations.\033[0m"
            break
            ;;
        "Save to a file" )
            default_filename="${first_three_digits}_[2-9]XXXX_${last_two_digits}_combinations.txt"
            read -p "Enter filename to save (default: $default_filename): " output_filename
            output_filename=${output_filename:-$default_filename} # Use default if empty

            echo -e "\nGenerating and saving $total_combinations numbers to: \033[36m$output_filename\033[0m"
            echo "Are you sure you want to proceed with saving to this file?"
            read -p "(y/n): " confirm_save
            # Convert to lowercase for case-insensitive comparison
            confirm_save_lower=$(echo "$confirm_save" | tr '[:upper:]' '[:lower:]')
            if [[ "$confirm_save_lower" != "y" && "$confirm_save_lower" != "yes" ]]; then # Accept 'y' or 'yes'
                echo "Operation cancelled."
                exit 0
            fi

            count=0
            echo "Starting generation (Progress: one '.' per 1000 numbers):"
            temp_progress_file=$(mktemp)

            # Perform generation
            (
                inner_count_save=0 # Use a different variable name for the subshell
                for i in $(seq 20000 99999); do
                    middle_five_digits=$(printf "%05d" "$i")
                    echo "${first_three_digits}${middle_five_digits}${last_two_digits}" >> "$output_filename"
                    inner_count_save=$((inner_count_save + 1))
                    if (( inner_count_save % 1000 == 0 )); then
                        echo -n "." >> "$temp_progress_file"
                    fi
                done
            ) & # Run in subshell for cleaner progress

            pid=$!
            # Display progress from temp file
            while kill -0 $pid 2>/dev/null; do
                if [ -s "$temp_progress_file" ]; then
                    cat "$temp_progress_file"
                    # shellcheck disable=SC2034 # This variable is used to clear the file below
                    current_progress_output=$(cat "$temp_progress_file")
                    truncate -s 0 "$temp_progress_file" # Clear the temp file after reading
                fi
                sleep 0.1
            done
            wait $pid # Wait for the subshell to finish

            # Final count from the file itself is most reliable
            if [ -f "$output_filename" ]; then
                final_count=$(wc -l < "$output_filename" | tr -d ' ')
            else
                final_count=0
            fi

            rm "$temp_progress_file"
            echo -e "\n\033[1;32mGeneration complete. Saved $final_count combinations to \033[36m$output_filename\033[0m.\033[0m"
            break
            ;;
        "Cancel" )
            echo "Operation cancelled."
            exit 0
            ;;
        * )
            echo "Invalid option. Please select 1, 2, or 3."
            ;;
    esac
done

exit 0

