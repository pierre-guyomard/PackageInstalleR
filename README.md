# PackageInstalleR


“An easy way to install R packages”

Author : Pierre GUYOMARD (piguyomard@outlook.com)

R version : 3.6.1 and further



What is PackageInstalleR ?

PackageInstalleR is a script, for R 3.6.1 and further, which installs several packages from several sources (CRAN, BioConductor and GithHub). The input consists in a tsv file in which package name are written in the first column. The output named “installation_output.tsv” contains the name of the package and the source of installation.

The code is available here :  https://github.com/pierre-guyomard/PackageInstalleR/blob/main/PackageInstalleR.r



How does it work ?

The script processes by successive installation from each source, starting with CRAN and ending with GitHub. After a successful installation from a source, the package is available but not loaded. It is the purpose of the function bibliotheque. This function is initialized to FALSE. If package installation is a success, package can be loaded and bibliotheque is changed to TRUE. Whilst bibliotheque value is FALSE, installation is attempted with is another source. As soon as bibliotheque value is TRUE, installation process is aborted. By default, the script will not close the R session. Workflow is available here :
https://drive.google.com/file/d/1XDPN_9MTlkBEOOJ3G5siOO8OULhhvba6/view?usp=sharing



How use PackageInstalleR ?

Prepare the list (tsv file) of package, taking account of the case, in one column. Save it in the current R directory.
Start R, source the script and type “installation(“quit_option”). By default, quit_option is set to “no”.



Main functions

•	bibliotheque : 
Function charged to check the success of installation from each source.

•	verification_package : 
Function which manages overlooking the list of package and output file. If the package is not already installed, this function will call the function installation_package_cran.

•	installation_package_cran : 
Manage the installation from CRAN. If installation which CRAN fails, it calls the function installation_package_BioConductor.

•	installation_package_BioConductor : 
Manage the installation from BioConductor. If installation which BioConductor fails, it calls the function installation_package_GitHub.

•	disponible : 
Checks if package is available on BioConductor or GitHub.

