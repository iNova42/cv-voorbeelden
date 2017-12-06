# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup #to parse the pages that are retrieved
import urllib.request #to retrieve the pages containing the vacatures
import time
from selenium import webdriver
import re #regular expressions so I can get the url with a non-buildin wildcard like the damned pleb I end up being
import traceback # but atleast I'm not handling exceptions like a pleb, this will add a full traceback to the exception print, should've been standard in python tho
import codecs
import calendar

# cd C:\Users\Admin\Desktop\pyvacature -:- python vacature.py

"""
!!!!!!!!!!!!!!!IMPORTANT!!!!!!!!!
Add a number telling how many vacatures were excluded for each exclusion keyword.
example: 
36 thuishulp/kuishulp/kuis*/schoonma*
12 beenhouwer
etc. in red with prob dropdown

Spec:
-Should add something that decides exclusion by combining type of job with location
 For example: Bakkerij + GENTBRUGGE + (Weekendwerk OR feestdagen) = exclusion (as earliest train there arrives way too late in the weekend)
"""

"""
		Main function handling the loop
"""
def main():
	try:
		driver = webdriver.Chrome('C:/Users/Admin/Desktop/pyvacature/chromedriver.exe')  # Optional argument, if not specified will search path
		
		"""
				Set the site query url
		"""
		VDABsite_url = 'https://www.vdab.be/jobs/vacatures?dagweekmaand=9000&diploma_niveau=C&diploma_niveau=B&diploma_niveau=A&ervaring=2&ervaring=1&ervaring=0&jobdomein=JOBCAT02&jobdomein=JOBCAT05&jobdomein=JOBCAT08&jobdomein=JOBCAT12&jobdomein=JOBCAT13&jobdomein=JOBCAT15&jobdomein=JOBCAT17&jobdomein=JOBCAT21&jobdomein=JOBCAT23&jobdomein=JOBCAT24&jobdomein=JOBCAT10&wat=-Elektricien%20-Ingenieur%20-Monteur%20-Jobstudent%20-Chauffeur%20-heftruck%20-Onderhoudstechnieker%20-Verzorgende%20-Grondwerker%20-Supply%20-Technicus%20-Management%20-STUDENT%20-Metser%20-Pistoolschilder%20-Technieker%20-Hulpkok%20-Boekhouder%20-Teamleader%20-Account&locode=2566&afstand=20&waar=9160%20Lokeren'
		
		"""
				Setup things continuously needed by each page loop
		"""
		calendar
		#f = open("Current_"+datetime.datetime.now()+".html", "wt")
		f = open("current02"+".html", "wt")
		f.close()
		#f = open("Current_"+datetime.datetime.now()+".html", "a")
		f = open("current02"+".html", "a")
				
		output_line_counter = 0
		
		excludedPage = open("Excluded_output.html", "wt")
		excludedPage.close()
		excludedPage = open("Excluded_output.html", "a")
		
		Excl_output_line_counter = 0
		
		problematic_interimsList = ["Let's Work", "Vivaldis Interim"]
		problematic_areaList = ["SINT-NIKLAAS"]
		unreachable_locationList = ["AALST", "BERLARE", "BORNEM", "BUGGENHOUT", "DESTELBERGEN", "DESTELDONK", "ERPE-MERE", "ERTVELDE", "EVERGEM", "GIJZEGEM", "HAMME", "HERDERSEM", "HEUSDEN", "KALKEN", "LAARNE", "LEDE", "LEBBEKE", "MELLE", "MELSELE", "MERELBEKE", "MOORSEL", "NIEUWERKERKEN", "OOSTAKKER", "OPWIJK", "Regio Aalst", "SCHOONAARDE", "SERSKAMP", "SINT-AMANDS", "SINT-GILLIS-WAAS", "SINT-KRUIS-WINKEL", "SINT-PAUWELS", "TEMSE", "VRASENE", "WAASMUNSTER", "WACHTEBEKE", "WETTEREN", "WICHELEN", "WIEZE", "ZELZATE"]
		currently_excluded_jobsList = ["Beenhouwer", "Huishoudhulp", "Thuishulp", "Boekhouder", "Operator", "Chauffeur", "Laborant", "SOLUTION OWNER", "VERTEGENWOORDIGER"]
		exclusion_candidates_List = ["chemie", ""]
		
		url_ID_List = []
		url_ID_List.append(00000000) #a dummy addition
		exclusionsList = []
		
		"""
				Preform the loop on each page
		"""
		#De website geeft nooit meer dan 20 pagina's aan resultaten voor een query.
		for i in range(20):
			n = i+1
			if n < 10:
				n = str(n)
				n = "0"+n
			else:
				n = str(n)
			driver.get(VDABsite_url+'&p='+n)
			time.sleep(3)
			html = driver.page_source
			html = html.encode("ascii", "ignore") #removes all the non-ascii characters, it's basicly a simple solution for badly encoded characters
			html = html.decode('ascii', 'strict')
			soup = BeautifulSoup(html)
			#\d matches [0-9] and other digit characters, for example Eastern Arabic numerals ٠١٢٣٤٥٦٧٨٩
			job_title_html_List = soup.findAll("a", attrs={ 'href':re.compile(r'/jobs/vacatures/\d.*')} )
			employers_html_List = soup.findAll("strong", attrs={'data-ng-bind-html':'vacature.naam_vestiging.value'} )
			locations_html_List = soup.findAll("strong", attrs={'data-ng-if':re.compile(r'(vacature.gemeente|vacature.regio_naam)$')} ) 
			#previous line uses pipe(=OR) regex together with $ to indicating "anything that includes", so anything that includes this or that in it's name

			if not len(locations_html_List) == len(job_title_html_List) == len(locations_html_List):
				raise ValueError('mismatch, values missing in scraping',  len(locations_html_List), len(job_title_html_List), len(locations_html_List))
			
			counter = -1
			for job_title in job_title_html_List:
				counter += 1
				#Gets the vacature link url with identification nr
				printvar = job_title['href'].split('?') #this gives a list with 2 items
				#print (printvar[0]) #gives the url
				url_ID = printvar[0][16:-1] #trims off all but the ID
				#print ("url_ID:"+url_ID)
				for ID in url_ID_List:
					if(str(ID) == str(url_ID)):
						doubleID = True
					else:
						add_it = True
					'''decomment the next line and find why double ID is still happening'''
					#print('"'+str(ID)+'"'+' against '+'"'+str(url_ID)+'"')
				if add_it == True: #since we can't add it for every time it returns to not match
					url_ID_List.append(url_ID)
					doubleID = False
				"""
						Checks if the vacature is in a problematic region found within interimsList (want 
						een kantoor in sint-niklaas kan voor bornem zoeken dus moeten deze apart bekeken/verwerkt worden)
				"""
				#print(str(employers_html_List[counter]).split('>')[:-8])
				#sleep(5)
				problem_interim = False
				problem_area = False #not putting it in else in case list becomes empty
				for interim in problematic_interimsList:
					if interim == str(employers_html_List[counter]).split('>')[1][:-8]:
						problem_interim = True
				for area in problematic_areaList:
					if area == str(locations_html_List[counter]).split('>')[1][:-8]:
						problem_area = True
				#Check if it's alright by surfing the vacature directly:
				if problem_interim == True and problem_area == True:
					dummy = 0
					#implement this later, if at all, lowest priority
				
				"""
						Checks if the vacature is in an unreachable region, adding it to exclusions list
				"""
				
				if(doubleID == False):
					for location in unreachable_locationList:
						if location == str(locations_html_List[counter]).split('>')[1][:-8]:
							Excl_output_line_counter += 1
							#excludedPage.write("<span>"+str(Excl_output_line_counter)+": </span>"+'<a href="https://www.vdab.be/'+str(job_title)[791:]+'<br>')
							'''test, remember to restore to commented line if not happy with new way'''
							excludedPage.write("<span>"+str(Excl_output_line_counter)+": </span>"+str(job_title)[791:]+'<br>')
							doubleID = True #..should think on var name that's more fitting/descriptive
				"""
						Write out to the output page
				"""
				if(doubleID == False):
					output_line_counter += 1
					#f.write("<div><span>"+str(output_line_counter)+": </span>"+'<a href="https://www.vdab.be/'+str(job_title)[791:]+'<br>')
					f.write("<div><span>"+str(output_line_counter)+": </span>"+'<a href="https://www.vdab.be/jobs/vacatures/'+str(url_ID)+'">'+
					str(job_title)[791+1+(str(job_title)[791:-4].rfind('>')):-4]+'</a><br>')
					print (str(job_title)[791:-4].rfind('>'))
					temp01 = (str(job_title)[791:-4]).rfind('>') + 791 + 1 #I'm a bit dissapointed in myself here, temp isn't exactly descriptive
					print (str(job_title)[(str(job_title)[791:-4].rfind('>')):])
					print (str(job_title)[temp01:-4])
					additional_space = 0
					if output_line_counter > 99:
						additional_space = 3
					elif output_line_counter > 9:
						additional_space = 1
					f.write('<span> &nbsp;&nbsp;&nbsp;'+('&nbsp;'*additional_space)+' </span>'+str(employers_html_List[counter])+'<span> in </span>'+str(locations_html_List[counter])+'<br><br></div>')

		#When leaving the loop.
		print('all done')
		driver.quit()
		
	except BaseException as e:
		print("something crashed during processing of page number "+n)
		traceback.print_exc() 
		#driver.quit() #Actally better to keep it running in the case of a crash, so webpage remains open as it was at that moment in the browser.
		


if __name__ == "__main__":
    main()
