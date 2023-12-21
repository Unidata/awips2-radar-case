# Unidata Radar Case

This repo includes the:
  - [KTLX](./radar_case-20130531/radar_data/KTLX)
  - [KFDR](./radar_case-20130531/radar_data/KFDR)
  - [KVNX](./radar_case-20130531/radar_data/KVNX)

level 3 radar for the 20130531 Oklahoma tornado outbreak. These data can be ingested into EDEX to re-create the case study that was used in the Asynchronous CAVE Training - TLO4 Radar "Challenge" section.

---

## Requesting New Radar Data from NCEI

1. Go to [NCEI's inventory by radar site](https://www.ncdc.noaa.gov/nexradinv/choosesite.jsp)
2. Select the radar site you are wanting (ex. KTLX) and click <b>Submit</b>
       ![select radar site](../images/selectRadar.png)
3. Choose the date, select *Level-III (Products) (ALL)* and click <b>Create Graph</b>
       ![choose date](../images/selectDate.png)
4. Enter your email address, select the valid times you want data, and click <b>Order Data</b>
5. Wait anywhere from a few minutes to a few hours and you will get an email.
6. Repeat for other radars needed.

## Downloading Radar Data from NCEI

1. You should receive an email with the link to your data. 
>Note: Your data will only be available for 5 days before being removed from the ftp server, so make sure to download it right away!

![email](../images/email.png)

2. In a terminal, create a directory where you would like to download the data, say `radar_case-20130531/radar_data` and change directories into that directory
3. Retreive the `fileList.txt` file by one of the following options:
   1. Use wget to download the fileList.txt file from the Web Download link
      - `wget https://www.ncei.noaa.gov/pub/has/HAS012457153/https://www.ncei.noaa.gov/pub/has/HAS012457153/fileList.txt`
   2. Open the file via the Web Download link
      - The link should look something like this: https://www.ncei.noaa.gov/pub/has/HAS012457153/https://www.ncei.noaa.gov/pub/has/HAS012457153/
      - Once open in a browser, click on the `fileList.txt`
      - You copy the text from the browser and paste it into the a text file in your terminal
   3. Download the file via command line:
        - Connect to the ftp server: `ftp ftp:ncei.noaa.gov`

                awips@radar ~]$ ftp ftp.ncei.noaa.gov
                Trying 205.167.25.137...
                Connected to ftp.ncei.noaa.gov (205.167.25.137).
                220-****** WARNING ** WARNING ** WARNING ** WARNING ** WARNING ** ** WARNING ** WARNING ** WARNING ******
                ** You are accessing a U.S. Government information system, which includes:                         **
                ** 1) This computer, 2)This computer network, 3) All computers connected to this network, and      **
                ** 4) All devices and storage media attached to this network or to a computer on this network.     **
                ** You understand and consent to the following:                                                    **
                ** you may access this information system for authorized use only; you have no reasonable          **
                ** expectation of privacy regarding any communication of data transiting or stored on this         **
                ** information system; at any time and for any lawful Government purpose, the Government may       **
                ** monitor, intercept, and search and seize any communication or data transiting or stored on      **
                ** this information system; and any communications or data transiting or stored on this            **
                ** information system may be disclosed or used for any lawful Government purpose.                  **
                ****** WARNING ** WARNING ** WARNING ** WARNING ** WARNING ** ** WARNING ** WARNING ** WARNING ******
                220 ::ffff:205.167.25.137 FTP server ready
                Name (ftp.ncei.noaa.gov:awips): 

        - It will ask you for your name, you can type: `anonymous`

                Name (ftp.ncei.noaa.gov:awips): anonymous
                331 Anonymous login ok, send your complete email address as your password
                Password:

        - Next it will ask you for a password, just press `ENTER`
        - Now change directory into the path specified in the email, this will start with `pub/has/HAS[#############]`, where the number is specific to your order: `cd pub/has/HAS012457153/`
        - You can use `dir` to see a list of directories and files

                ftp> dir
                227 Entering Passive Mode (205,167,25,137,236,228).
                150 Opening ASCII mode data connection for file list
                drwxr-xr-x   2 ftp      ftp           102 Dec 20 16:48 0001
                drwxr-xr-x   2 ftp      ftp           102 Dec 20 16:48 0002
                drwxr-xr-x   2 ftp      ftp           102 Dec 20 16:48 0003
                drwxr-xr-x   2 ftp      ftp           102 Dec 20 16:49 0004
                drwxr-xr-x   2 ftp      ftp           102 Dec 20 16:49 0005
                drwxr-xr-x   2 ftp      ftp           102 Dec 20 16:49 0006
                drwxr-xr-x   2 ftp      ftp           102 Dec 20 16:49 0007
                drwxr-xr-x   2 ftp      ftp           102 Dec 20 16:49 0008
                drwxr-xr-x   2 ftp      ftp            22 Dec 20 16:49 0009
                -rw-r--r--   1 ftp      ftp         30340 Dec 20 16:49 fileList.txt
                226 Transfer complete

        - Type `prompt` to turn off interactive mode
        - Use mget, to download the file: `mget fileList.txt`
        - Exit out of ftp: `exit`
4. Once you have this file downloaded, rename it as `KXXX-fileList.txt` where `KXXX` is the radar site you selected
5. Repeat steps 3 and 4 until you have all of the fileList.txt files for each radar
6. Once all the KXXX-fileList.txt files have been saved off, update the `downloadData.pl` script with the radar files and download directories:

        @radars=('KTLX','KFDR','KVNX');
        @downloads=('HAS012457153','HAS012449084','HAS012449083');

7. Run `perl downloadData.pl` (this may take several hours depending on how much data you are downloading)

## Ingesting Radar Data
Now the data are downloaded, you are almost ready to ingest the data. You just need to disable purging and update the distribution file.

1. Disable purging so the archived data thare you are ingesting don't immediately get purged. 
   - `vi /awips2/edex/conf/resources/purge.properties`
   - set: `purge.enabled=false`
   - Restart edex_camel: `sudo service edex_camel restart ingest`
2. Update the distribution file to match some portion of the file pattern of the files you downloaded:
   - `vi "/awips2/edex/data/utility/common_static/base/distribution/radar.xml`
     
            <regex>KOUN.*</regex>

3.  Now copy the data to the manual endpoint: `rsync -aP K* /awips2/edex/data/manual/`
