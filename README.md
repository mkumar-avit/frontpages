<H1>Description</H1>

Will pull front page of newspapers in PDF format.  May need to obtain permissions from Newseum.com or individual newspapers for continual use.

This is designed to be used on digital signage in a portrait orientation.   The user can schedule the Powershell script to run once or twice daily, and it will pull front page of newspapers and trigger chrome to display and randomly rotate through the PDFs.


If needed resolution and refresh times can be updated in the script along with what newspapers are downloaded.  The concept is based around something I saw at the University of North Carolina Hunt Library, though I never saw how they originally programmed this.



<H3>Recommended values</H3>
$refreshTime = 45


<H3> Future Developments </H3>
Will be working on an option to automatically pull newspaper names and randomizing which one gets selected for viewing, instead of using a manually generated array.

