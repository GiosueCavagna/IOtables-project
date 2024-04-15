# IOtables-project
Here is possible to find my codes used for Input/Output table analysis.

# Data
This code works on the IO tables avaliable on the OECD database at the link: https://www.oecd.org/sti/ind/inter-country-input-output-tables.html. The Database is strucutred with the names of eahc countries followed by the International Standard Industry Classification (ISIC) Rev 4.

# Code structure
The goal of this code is to create an infrastructure able to easily define the sector as list of the industries, and the region as list of countries. Once defined these two cluster in the second section, in the remaining sections are computed the sum over the tables so that to compute the desired output.

# Main algorithm
The main algorithms exploit the names of the coloumns and of the rows, which are always of the form COUNTRY_INDUSTRY, allowing to easily create a string str=['country','_','indutry'] which exactly refer to the desiderd column. The position of this string is the found with the command contains. Once the index with the position of all the indutries in our sector for each country of our region is created, it remain just to sum the column.
If it is wanted to create a sectorial union also on the rows, that is at the input level, is enough to either transpose the database and sum over the column (as I do) or directly sum over the rows.

