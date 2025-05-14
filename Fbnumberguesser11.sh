#!/bin/bash

print_header() {
    echo -e "\033[1;34m--------------------------------------------------\033[0m"
    echo -e "\033[1;34m   Bash 11-Digit Phone Number Combination Generator \033[0m"
    echo -e "\033[1;34m          (Generates all possible       \033[0m"
    echo -e "\033[1;34m            middle 6 digits)   \033[0m"
    echo -e "\033[1;34m--------------------------------------------------\033[0m"
    echo -e "\033[3mThis tool generates 11-digit phone number combinations.\033[0m\n"
}

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

while true; do
    read -p "Enter the first 3 known digits: " first_three_digits
    if validate_digits "$first_three_digits" 3; then
        break
    else
        echo -e "\033[31mInvalid input. Please try again.\033[0m"
    fi
done

while true; do
    read -p "Enter the last 2 known digits: " last_two_digits
    if validate_digits "$last_two_digits" 2; then
        break
    else
        echo -e "\033[31mInvalid input. Please try again.\033[0m"
    fi
done

echo -e "\n\033[1mInputs received:\033[0m Prefix: \033[36m$first_three_digits\033[0m, Suffix: \033[36m$last_two_digits\033[0m"

total_combinations=1000000

echo "How would you like to output the combinations?"
select output_choice in "Print to console" "Save to a file" "Cancel"; do
    case $output_choice in
        "Print to console" )
            echo -e "\nGenerating and printing $total_combinations numbers for: \033[36m${first_three_digits}\033[0mXXXXXX\033[36m${last_two_digits}\033[0m"
            echo "This will print $total_combinations lines. Proceed?"
            read -p "(y/n): " confirm_print
            confirm_print_lower=$(echo "$confirm_print" | tr '[:upper:]' '[:lower:]')
            if [[ "$confirm_print_lower" != "y" && "$confirm_print_lower" != "yes" ]]; then
                echo "Operation cancelled."
                exit 0
            fi

            count=0
            echo "Starting generation (Progress: one '.' per 10000 numbers):"
            for i in $(seq 0 999999); do
                middle_six_digits=$(printf "%06d" "$i")
                echo "${first_three_digits}${middle_six_digits}${last_two_digits}"
                count=$((count + 1))
                if (( count % 10000 == 0 )); then
                    echo -n "."
                fi
            done
            echo -e "\n\033[1;32mGeneration complete. Printed $count combinations.\033[0m"
            break
            ;;
        "Save to a file" )
            default_filename="${first_three_digits}_XXXXXX_${last_two_digits}_combinations.txt"
            read -p "Enter filename to save (default: $default_filename): " output_filename
            output_filename=${output_filename:-$default_filename}

            echo -e "\nGenerating and saving $total_combinations numbers to: \033[36m$output_filename\033[0m"
            echo "Are you sure you want to proceed with saving to this file?"
            read -p "(y/n): " confirm_save
            confirm_save_lower=$(echo "$confirm_save" | tr '[:upper:]' '[:lower:]')
            if [[ "$confirm_save_lower" != "y" && "$confirm_save_lower" != "yes" ]]; then
                echo "Operation cancelled."
                exit 0
            fi

            count=0
            echo "Starting generation (Progress: one '.' per 10000 numbers):"
            temp_progress_file=$(mktemp)

            (
                inner_count_save=0
                for i in $(seq 0 999999); do
                    middle_six_digits=$(printf "%06d" "$i")
                    echo "${first_three_digits}${middle_six_digits}${last_two_digits}" >> "$output_filename"
                    inner_count_save=$((inner_count_save + 1))
                    if (( inner_count_save % 10000 == 0 )); then
                        echo -n "." >> "$temp_progress_file"
                    fi
                done
            ) &
            
            pid=$!
            while kill -0 $pid 2>/dev/null; do
                if [ -s "$temp_progress_file" ]; then
                    cat "$temp_progress_file"
                    current_progress_output=$(cat "$temp_progress_file") 
                    truncate -s 0 "$temp_progress_file"
                fi
                sleep 0.1
            done
            wait $pid
            
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

