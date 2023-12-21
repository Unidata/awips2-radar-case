#!/usr/bin/perl


@radars=('KTLX','KFDR','KVNX');
@downloads=('HAS012457153','HAS012449084','HAS012449083');

$subDir="radar_data";

for($i=0; $i<=$#radars; $i++)
{
  open IN, "$subDir/$radars[$i]-fileList.txt" or die "Cannot open\n";
  @lines=<IN>;

  `mkdir $subDir/$radars[$i]`;

  foreach $line(@lines)
  {
    chomp $line;
    `cd $subDir/$radars[$i] ; wget ftp://ftp.ncei.noaa.gov/pub/has/$downloads[$i]/$line`; 
  }

}
