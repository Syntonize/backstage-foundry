def lambda_handler(event: dict[str, str], context: dict[str, str]) -> None:
    print(f"Running for event: {event} and context: {context}")
    main()

def main() -> None:
    print("Hello from main")

if __name__ == "__main__":
    main()
