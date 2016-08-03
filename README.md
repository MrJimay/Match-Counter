# Match-Counter
Check how many times certain patterns occur within a csv or similar text file.

Can pass in an entire file containing lines of regex to search for multiple regex patterns in one go.

Has an option to open up an output file on top of returning the number of matches. The file contains all the results that matched your regex in case the number of matches seems off and you want to manually confirm.

Currently only works for comma separated data (if there is more than one column of data you want to search through).
E.g. 
Smith, John
Lee, Ping
Paul, Paul
