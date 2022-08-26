defmodule Identicon do
  @moduledoc """
  Module that creates an Identicon from a string.
  """

  @doc """
  Combination of all other methods: hash_input -> pick_color -> build_grid -> filter_odd_squares -> build_pixel_map -> draw_image -> save_image.

  ## Example

  ```
  iex> Identicon.main("username")
  :ok
  ```
  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
  Returns a list of 16 integers ranging from 0 to 255 from a binary MD5 hash calculated from an input string and set to hex field of Identicon.Image struct.

  ## Example

  ```
  iex> hash_input = Identicon.hash_input("username")
  iex> hash_input.hex
  [20, 196, 176, 107, 130, 78, 197, 147, 35, 147, 98, 81, 127, 83, 139, 41]
  ```
  """
  def hash_input(input) do
    %Identicon.Image{
      hex:
        :crypto.hash(:md5, input)
        |> :binary.bin_to_list()
    }
  end

  @doc """
  Returns a tuple that matches the rgb variables of a color and set to color field of Identicon.Image struct.

  ## Example

  ```
  iex> pick_color = Identicon.pick_color(%Identicon.Image{hex: [20, 196, 176, 107, 130, 78, 197, 147, 35, 147, 98, 81, 127, 83, 139, 41]})
  iex> pick_color.color
  {20, 196, 176}
  ```
  """

  def pick_color(image) do
    %Identicon.Image{
      image
      | color:
          Enum.split(image.hex, 3)
          |> Kernel.elem(0)
          |> List.to_tuple()
    }
  end

  @doc """
  Returns a list of tuples and set to grid field of Identicon.Image struct. Each tuple contains the value and index of the grid.

  ## Example

  ```
  iex> build_grid = Identicon.build_grid(%Identicon.Image{hex: [20, 196, 176, 107, 130, 78, 197, 147, 35, 147, 98, 81, 127, 83, 139, 41], color: {20, 196, 176}})
  iex> build_grid.grid
  [
    {20, 0},
    {196, 1},
    {176, 2},
    {196, 3},
    {20, 4},
    {107, 5},
    {130, 6},
    {78, 7},
    {130, 8},
    {107, 9},
    {197, 10},
    {147, 11},
    {35, 12},
    {147, 13},
    {197, 14},
    {147, 15},
    {98, 16},
    {81, 17},
    {98, 18},
    {147, 19},
    {127, 20},
    {83, 21},
    {139, 22},
    {83, 23},
    {127, 24}
  ]
  ```
  """

  def build_grid(image) do
    # & pass reference to mirrow_row function
    # /1 is the function arity
    %Identicon.Image{
      image
      | grid:
          Enum.chunk_every(image.hex, 3, 3, :discard)
          |> Enum.map(&mirror_row/1)
          |> List.flatten()
          |> Enum.with_index()
    }
  end

  @doc """
  Mirror the list.

  ## Example

  ```
  iex> mirrored_row = Identicon.mirror_row([20, 196, 176])
  iex> mirrored_row
  [20, 196, 176, 196, 20]
  ```
  """

  def mirror_row(row) do
    # The pipe ("|") ignores everything else in the list
    [first, second | _tail] = row
    # concatenate the two lists
    row ++ [second, first]
  end

  @doc """
  Remove odd values from the grid.

  ## Example

  ```
  iex> filter_odd_squares = Identicon.filter_odd_squares(%Identicon.Image{hex: [20, 196, 176, 107, 130, 78, 197, 147, 35, 147, 98, 81, 127, 83, 139, 41], color: {20, 196, 176}, grid: [{20, 0},{196, 1},{176, 2},{196, 3},{20, 4},{107, 5},{130, 6},{78, 7},{130, 8},{107, 9},{197, 10},{147, 11},{35, 12},{147, 13},{197, 14},{147, 15},{98, 16},{81, 17},{98, 18},{147, 19},{127, 20},{83, 21},{139, 22},{83, 23},{127, 24}]})
  iex> filter_odd_squares.grid
  [
  {20, 0},
  {196, 1},
  {176, 2},
  {196, 3},
  {20, 4},
  {130, 6},
  {78, 7},
  {130, 8},
  {98, 16},
  {98, 18}
  ]
  ```
  """

  def filter_odd_squares(image) do
    %Identicon.Image{
      image
      | grid: Enum.filter(image.grid, fn {value, _index} -> rem(value, 2) === 0 end)
    }
  end

  @doc """
  Returns a list of tuples with the coordinates to paint the image and set to pixel_map field of Identicon.Image struct.

  ## Example

  ```
  iex> build_pixel_map = Identicon.build_pixel_map(%Identicon.Image{hex: [20, 196, 176, 107, 130, 78, 197, 147, 35, 147, 98, 81, 127, 83, 139, 41], color: {20, 196, 176}, grid: [{20, 0},{196, 1},{176, 2},{196, 3},{20, 4},{130, 6},{78, 7},{130, 8},{98, 16},{98, 18}]})
  iex> build_pixel_map.pixel_map
  [
  {{0, 0}, {50, 50}},
  {{50, 0}, {100, 50}},
  {{100, 0}, {150, 50}},
  {{150, 0}, {200, 50}},
  {{200, 0}, {250, 50}},
  {{50, 50}, {100, 100}},
  {{100, 50}, {150, 100}},
  {{150, 50}, {200, 100}},
  {{50, 150}, {100, 200}},
  {{150, 150}, {200, 200}}
  ]
  ```
  """

  def build_pixel_map(image) do
    # Here we assume that the image has 5 squares of sides 50 px each, thus totaling a square image 250x250 px 
    %Identicon.Image{
      image
      | pixel_map:
          Enum.map(image.grid, fn {_value, index} ->
            horizontal = rem(index, 5) * 50
            vertical = div(index, 5) * 50
            top_left = {horizontal, vertical}
            bottom_right = {horizontal + 50, vertical + 50}
            {top_left, bottom_right}
          end)
    }
  end

  @doc """
  Returns the binary of Identicon image.

  ## Example

  ```
  iex> drawn_image = Identicon.draw_image(%Identicon.Image{hex: [20, 196, 176, 107, 130, 78, 197, 147, 35, 147, 98, 81, 127, 83, 139, 41], color: {20, 196, 176}, grid: [{20, 0},{196, 1},{176, 2},{196, 3},{20, 4},{130, 6},{78, 7},{130, 8},{98, 16},{98, 18}], pixel_map: [{{0, 0}, {50, 50}},{{50, 0}, {100, 50}},{{100, 0}, {150, 50}},{{150, 0}, {200, 50}},{{200, 0}, {250, 50}},{{50, 50}, {100, 100}},{{100, 50}, {150, 100}},{{150, 50}, {200, 100}},{{50, 150}, {100, 200}},{{150, 150}, {200, 200}}]})
  iex> is_binary(drawn_image)
  true
  ```
  """

  # pattern matching in function argument
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  @doc """
  Saves the Identicon image in the directory.

  ## Example

  ```
  iex> drawn_image = Identicon.draw_image(%Identicon.Image{hex: [20, 196, 176, 107, 130, 78, 197, 147, 35, 147, 98, 81, 127, 83, 139, 41], color: {20, 196, 176}, grid: [{20, 0},{196, 1},{176, 2},{196, 3},{20, 4},{130, 6},{78, 7},{130, 8},{98, 16},{98, 18}], pixel_map: [{{0, 0}, {50, 50}},{{50, 0}, {100, 50}},{{100, 0}, {150, 50}},{{150, 0}, {200, 50}},{{200, 0}, {250, 50}},{{50, 50}, {100, 100}},{{100, 50}, {150, 100}},{{150, 50}, {200, 100}},{{50, 150}, {100, 200}},{{150, 150}, {200, 200}}]})
  iex> Identicon.save_image(drawn_image, "username")
  :ok
  ```
  """

  def save_image(image_file, filename) do
    File.write("#{filename}.png", image_file)
  end
end
