# IOtables-project
Here is possible to find my codes used for Input/Output table analysis.

# Data
This code works on the IO tables avaliable on the OECD database at the link: https://www.oecd.org/sti/ind/inter-country-input-output-tables.htm

# Code structure
The goal of this code is to create an infrastructure able to easily define the sector as list of the industries, and the region as list of countries. Once defined these two cluster in the second section, the remaining one sum over the tables so that compute the desired output.

# Main algorithm
The main algorithms exploit the names of the coloumns and of the rows which are always of the form COUNTRY_INDUSTRY, allowing to easily create a string as ['country','_','indutry']. The position of this string is the found with the command contains. Once the index with the position of all the indutries in our sector for each coutnries of our region is created, it remain just to sum the column.
