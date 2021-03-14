########################################################
########################################################
#PackageInstalleR

# R 3.6.1 and further

#author : Pierre GUYOMARD 15.11.2020
#piguyomard@outlook.com

#https://github.com/pierre-guyomard/PackageInstalleR/blob/main/PackageInstalleR.r 

#this script is under GNU licence
########################################################
########################################################



#check availability of package after the installations
bibliotheque <- function(package, LOAD_SUCCESS) {

	package <- toString(package)

	if (library(package, logical.return = TRUE, character.only = TRUE, quietly = TRUE) == TRUE) {

		LOAD_SUCCESS <- TRUE

	}

	return(LOAD_SUCCESS)

}


#give the repository of a package
reposit_github <- function(package) {
     
     reposit <- as.list(gh_search_packages(package)[1])
     
     reposit <- reposit$username
     
     if (length(reposit) == 0 ) {
      
        reposit <- "NA"
            
     }
     
     return(reposit)
     
}



#check if package is available on BioConductor or GitHub
disponible <- function(COMPTEUR_INSTALLATION, package) {
     
     	if (COMPTEUR_INSTALLATION == "not_CRAN") { #if install with BioConductor
          
          	dispo <- as.list(BiocManager::available(package))
          	
          	if (length(dispo) >= 1 ) {
          	     
          	     dispo <- dispo[[1]]
          	     
          	     return(dispo)
          	
          	} 
          	
          	if (length(dispo) == 0 ) { #if "dispo" list if empty, returns "NA"
          	     
          	     dispo <- "NA"
          	     
          	     return(dispo)
          	     
          	}         
          
     	}
     
     	if (COMPTEUR_INSTALLATION == "not_BioConductor") { #if install with GitHub
          
          	dispo <- as.list(gh_search_packages(package)[2])
          	
          	if (length(dispo) == 0 ) { #if "dispo" list if empty, returns "NA"
          	     
          	     dispo <- "NA"
          	     
          	     return(dispo)
          	     
          	}
          	     
          	if (length(dispo) != 0) { 
          	     
          	     dispo <- dispo$package_name
          	     
          	     return(dispo)
          	
          	} 
          
     	}
     
}
          



some_tools <- function() { #some tools are required before installing packages. It uses the main script
     
	print(paste("log -- installing some tools ", sep = ""))
	
	if (R.version$os == 'linux-gnu') {
	
		tools <- c("BiocManager")
	
	}
	
	if (R.version$os != 'linux-gnu') {
	
		tools <- c("githubinstall", "devtools", "BiocManager")
	
	}
          
	verification_package(tools, "no", TRUE)
     
	st <- TRUE
     
	return(st)
     
}



#installation GitHub
installation_package_GitHub <- function(package, LOAD_SUCCESS, COMPTEUR_INSTALLATION) { #takes in charge the installation from GitHub
     
	dispo <- disponible(COMPTEUR_INSTALLATION, package)
	
	reposit <- reposit_github(package)
	
	if (length(dispo) != 0 | reposit != "NA" ) { #if there is at least one package and one accessible repository
	
	    TOO_MUCH_REPOSITS <- FALSE
     
		for (i in 1:length(dispo)) { 
		     
			if (length(dispo) < 2 & length(reposit) < 2 ) { #if there is not too much repositories and packages
		     
				for (k in 1:length(reposit)) { #install all corresponding package
		               
		            print(paste("log --\ ", package, "\ available on GitHub", sep = ""))
		               
		            install_github(paste(reposit[k], "/", package, sep =""))
		                    
                    }
		     
			}
				
			if (length(dispo) > 2 | length(reposit) > 2) { #if there is too much repositories or packages
		          
				while (TOO_MUCH_REPOSITS != TRUE) {
		          
		            print(paste("log --\ ", package, "\ please precise GitHub repository", sep = ""))
		               
		            TOO_MUCH_REPOSITS <- TRUE
		             
				}
		          
			}
			
		}
               
	}
	     
	LOAD_SUCCESS <- bibliotheque(package, LOAD_SUCCESS) #check successful installation
	
	if (LOAD_SUCCESS == FALSE) { #if GitHub installation do not succeeded 
	
		print(paste("log --\ ", package, "\ could not be installed with GitHub", sep = ""))

		print(paste("log --\ ", package, "\ could not be installed", sep = ""))
		
		COMPTEUR_INSTALLATION <- "Not_available"
		
		SORTIE <- c(LOAD_SUCCESS, COMPTEUR_INSTALLATION)
		
	}
	
	if (LOAD_SUCCESS == TRUE) { #if GitHub installation succeeded, leave installation process
		
		print(paste("log -- package ", package, "\ installed with GitHub", sep = ""))
	     
	     COMPTEUR_INSTALLATION <- "GitHub"
	     
	     SORTIE <- c(LOAD_SUCCESS, COMPTEUR_INSTALLATION)

	}

	return(SORTIE)
	
}


	

	


#installation BioConductor
installation_package_BioConductor <- function(package, LOAD_SUCCESS, COMPTEUR_INSTALLATION) { #takes in charge the installation from BioConductor

	dispo <- disponible(COMPTEUR_INSTALLATION, package) #checking availability package and name-related
	
	if (length(dispo) != 0) { #if name-related package are available on BioConductor
	
	     for (i in 1:length(dispo)) { 
	     
		     if (dispo[i] == package) { #installing the precise package
	          
		     	print(paste("log --\ ", package, "\ available on BioConductor", sep = ""))

		     	BiocManager::install(package, update = TRUE, ask = FALSE)
	          
		     }
		
	     }
	     
	}     

	LOAD_SUCCESS <- bibliotheque(package, LOAD_SUCCESS)

	if (LOAD_SUCCESS == FALSE) { #if BioConductor installation did not work, then install it with GitHub

		print(paste("log --\ ", package, "\ could not be installed with BioConductor", sep = ""))

		print(paste("log -- searching ", package, "\ on GitHub", sep = ""))
		
		COMPTEUR_INSTALLATION <- "not_BioConductor"
		
		SORTIE <- c(LOAD_SUCCESS, COMPTEUR_INSTALLATION)
		
		if (R.version$os != 'linux-gnu') {
			
			SORTIE <- installation_package_GitHub(package, LOAD_SUCCESS, COMPTEUR_INSTALLATION) #GitHub installation


		}
	}
	
	if (LOAD_SUCCESS == TRUE) { #if BioConductor installation did work, leaving installation process
	     
	     COMPTEUR_INSTALLATION <- "BioConductor"
	
		SORTIE <- c(LOAD_SUCCESS, COMPTEUR_INSTALLATION)
		
		print(paste("log -- package ", package, "\ installed with BioConductor", sep = ""))

	}

	return(SORTIE)
	
}







#installation CRAN
installation_package_cran <- function(package, LOAD_SUCCESS, COMPTEUR_INSTALLATION) { #takes in charge the installation from BioConductor

	install.packages(package, verbose = FALSE, keep_outputs = FALSE, repos = "https://cloud.r-project.org/")
     
	LOAD_SUCCESS <- bibliotheque(package, LOAD_SUCCESS) #check success of installation
     
	if (LOAD_SUCCESS == FALSE) { #if CRAN installation did not work, then install it with BioConductor

		print(paste("log -- package ", package, "\ could not be installed with CRAN", sep = ""))

		print(paste("log --  installing ", package, "\ with BioConductor", sep = ""))
		
		COMPTEUR_INSTALLATION <- "not_CRAN"

		SORTIE <- installation_package_BioConductor(package, LOAD_SUCCESS, COMPTEUR_INSTALLATION) #BioConductor installation

	}
	
	if (LOAD_SUCCESS == TRUE) { #if CRAN installation did work, leaving installation process
	     
	     COMPTEUR_INSTALLATION <- "CRAN"
	
		SORTIE <- c(LOAD_SUCCESS, COMPTEUR_INSTALLATION)
		
		print(paste("log -- package ", package, "\ installed with CRAN", sep = ""))

	}
	
	return(SORTIE)

}







verification_package <- function(liste, quit_option = "no", st = FALSE) { #check if package is alreary locally installed

	dataframe <- data.frame("Package", "Source") #manage output dataframe
	
	colnames(dataframe) <- c("PACKAGE", "SOURCE")
     
	if (st == FALSE) { #if tools are not installed, installing them
          
		st <- some_tools()
          
	}

	print(paste("log -- starting packages installaton ", sep = ""))
     
	liste <- sapply(liste, toString)

	for (k in 1:length(liste)) { #main loop to look over the list and install package
	
		LOAD_SUCCESS <- FALSE

		LOAD_SUCCESS <- bibliotheque(toString(liste[k]), LOAD_SUCCESS)
		
		COMPTEUR_INSTALLATION <- ""

		if (LOAD_SUCCESS == FALSE) { #if package is not locally available

			print(paste("log -- package ", toString(liste[k]), "\ is not locally available", sep = ""))

			print(paste("log -- installing ", toString(liste[k]), sep = ""))

			SORTIE <- installation_package_cran(toString(liste[k]), LOAD_SUCCESS, COMPTEUR_INSTALLATION)
			
		}
		
		if (LOAD_SUCCESS == TRUE) { #if package is locally available, checking the next package
		     
			print(paste("log -- package ", toString(liste[k]), "\ already installed and ready", sep = ""))
		     
		     COMPTEUR_INSTALLATION <- "Already_installed"
	
			SORTIE <- c(LOAD_SUCCESS, COMPTEUR_INSTALLATION)

		}
	    
		j <- k
	    
		if (j < length(liste)) { #manage display
		
			print(" ")
	         
			print(" ")
	         
			print(paste("log -- PACKAGE : ", toString(liste[j + 1]), sep = ""))
	         
	    	}
		
		if (st == TRUE) { #if not installing tools
		     
		     dataframe <- rbind(dataframe, c(toString(liste[k]), SORTIE[2]))
		     
		     write.table(dataframe, file = "installation_log.tsv", sep = "\t")
		     
		}
	
	}
	
	if (quit_option == "yes") {
	     
	    print(paste("log -- ", "installation completed, ", "now leaving R session", sep = ""))
	     
	   	quit(save = "yes")
	     
	}
	
}








PackageInstalleR <- function(liste = c(), quit_option = "no") { #function which manages installation
     
     print("PackageInstalleR is under GNU licence")
     
     print("PackageInstalleR : written by Pierre GUYOMARD")
     
     if (length(liste) == 0) {
     
          presence_input <- FALSE
     
          list_installation_input <- list.files()
     
          for (k in 1:length(list_installation_input)) {
          
               if (list_installation_input[k] == "installation_input.tsv") {
               
                    presence_input <- TRUE
               
                    liste <- as.list(read.delim(file = "installation_input.tsv", header = F, sep = "\t"))
               
                    liste <- liste$V1
               
               }
          
          }
    

          if (presence_input == FALSE) {
          
               liste <- readline("Prompt Package List :")
          
               liste <- unlist(strsplit(liste, ", "))
          
          }
          
     }
     
     verification_package(liste, quit_option)

}
