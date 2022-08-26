# Identicon generator

This project generates an Identicon similar to what Github defines as a user's profile picture from MD5 from an input string and was developed in elixir.

## Usage

1. Have the elixir installed on your machine.
2. After that, follow the steps:
   1. `mix deps.get`: install project dependencies.
   2. `iex -S mix`: open the interactive elixir.
   3. Inside interactive elixir, run: `Identicon.main(<YOUR_STRING_HERE>)`
   4. The Identicon must have been created in the root folder of the project with the name being the string you put as input.
   5. To check the documentation and understand what each method does: 
      1. Run `mix docs`.
      2. Open `doc/index.html` file.

## Useful mix commands

- `mix test`: executes all test cases in the project.
- `mix test <PATH_TO_TEST_FILE>`: run tests from a specific file.
- `mix format`: format all script files
