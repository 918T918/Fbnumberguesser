import time
from rich.console import Console
from rich.progress import Progress, BarColumn, TextColumn, TimeRemainingColumn
from rich.panel import Panel
from rich.text import Text
import questionary

def is_valid_digits(text, length):
    """Validator for questionary: checks if input is digits and of correct length."""
    if not text.isdigit():
        return "Input must contain only digits."
    if len(text) != length:
        return f"Input must be exactly {length} digits long."
    return True

def interactive_phone_generator_enhanced():
    """
    Interactively prompts for parts of a 10-digit phone number using an
    enhanced CLI interface, then generates and either prints or saves
    all possible combinations for the 5 middle digits.
    """
    console = Console()

    console.print(Panel(Text("Enhanced Phone Number Combination Generator", justify="center", style="bold blue"),
                        title="[bold green]Welcome![/bold green]",
                        expand=False))
    console.print("\nThis tool will help you generate all possible 10-digit phone numbers\n"
                  "based on the first 3 and last 2 known digits.", style="italic")

    first_three_digits = questionary.text(
        "Enter the first 3 known digits:",
        validate=lambda text: is_valid_digits(text, 3),
        qmark="🔑"
    ).ask()

    if first_three_digits is None: # User pressed Ctrl+C or similar
        console.print("\nProcess cancelled by user. Exiting.", style="bold red")
        return

    last_two_digits = questionary.text(
        "Enter the last 2 known digits:",
        validate=lambda text: is_valid_digits(text, 2),
        qmark="🔑"
    ).ask()

    if last_two_digits is None:
        console.print("\nProcess cancelled by user. Exiting.", style="bold red")
        return

    console.print(f"\n[bold green]Inputs received:[/bold green] Prefix: [cyan]{first_three_digits}[/cyan], Suffix: [cyan]{last_two_digits}[/cyan]")

    output_choice = questionary.select(
        "How would you like to output the combinations?",
        choices=[
            "Print to console",
            "Save to a file"
        ],
        qmark="?"
    ).ask()

    if output_choice is None:
        console.print("\nProcess cancelled by user. Exiting.", style="bold red")
        return

    total_combinations = 100000  # 10^5 for 5 middle digits

    if output_choice == "Print to console":
        console.print(f"\nGenerating and printing {total_combinations:,} possible numbers for: "
                      f"[cyan]{first_three_digits}[/cyan]XXXXX[cyan]{last_two_digits}[/cyan]")
        
        with Progress(
            TextColumn("[progress.description]{task.description}"),
            BarColumn(),
            TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
            TimeRemainingColumn(),
            console=console,
            transient=False # Keep progress bar after completion
        ) as progress:
            task = progress.add_task("[green]Generating numbers...", total=total_combinations)
            count = 0
            for i in range(total_combinations):
                middle_five_digits = "{:05d}".format(i)
                complete_number = f"{first_three_digits}{middle_five_digits}{last_two_digits}"
                # Printing every number can be very slow and flood the console.
                # Consider printing in batches or only a sample if this is an issue.
                # For now, as requested, printing all:
                console.print(complete_number, highlight=False) # highlight=False for faster printing
                progress.update(task, advance=1)
                count += 1
            # progress.stop() # Ensure progress is marked as finished
        console.print(f"\n[bold green]Successfully printed {count:,} combinations.[/bold green]")

    elif output_choice == "Save to a file":
        default_filename = f"{first_three_digits}XXXXX{last_two_digits}_combinations.txt"
        output_filename = questionary.text(
            "Enter the filename to save the combinations:",
            default=default_filename,
            qmark="💾"
        ).ask()

        if output_filename is None:
            console.print("\nProcess cancelled by user. Exiting.", style="bold red")
            return
        
        console.print(f"\nGenerating and saving {total_combinations:,} numbers to [cyan]{output_filename}[/cyan]...")
        count = 0
        try:
            with open(output_filename, 'w') as f:
                with Progress(
                    TextColumn("[progress.description]{task.description}"),
                    BarColumn(),
                    TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
                    TimeRemainingColumn(),
                    console=console,
                    transient=False
                ) as progress:
                    task = progress.add_task("[blue]Saving to file...", total=total_combinations)
                    for i in range(total_combinations):
                        middle_five_digits = "{:05d}".format(i)
                        complete_number = f"{first_three_digits}{middle_five_digits}{last_two_digits}"
                        f.write(complete_number + "\n")
                        progress.update(task, advance=1)
                        count += 1
                    # progress.stop()
            console.print(f"\n[bold green]Successfully saved {count:,} combinations to [cyan]{output_filename}[/cyan].[/bold green]")
        except IOError:
            console.print(f"[bold red]Error: Could not write to file {output_filename}. Check permissions.[/bold red]")

if __name__ == "__main__":
    interactive_phone_generator_enhanced()

