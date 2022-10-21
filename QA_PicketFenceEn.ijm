//*********************  Functions for obtaining and calculating data from images  **********************

function get_DICOM_data() { 
    //obtains DICOM image data
    data = newArray(3);
    
    Acelerator=getInfo("0008,1010"); // Gets information about the Accelerator	
	RTImageLabel = getInfo("3002,0002"); // To identify whether it is a test with or without INTENTED ERROR
	date=getInfo("0008,0022");	     // Gets information about the test's date

	Image_size=getWidth(); // Gets information about the Image size
	
	//Stores the values and then returns them in an array
	data[0]=Acelerator;
	data[1]=RTImageLabel;
	data[2]=Image_size;
	
	if(date != "")
		{
		datesP = newArray(3);
	    datesP[0] = substring(date, 1, 5);
	    datesP[1] = substring(date, 5, 7);
	    datesP[2] = substring(date, 7, 9);  	
	    };
    else {
	    datesP = newArray(3);
	    datesP[0] = "--";
	    datesP[1] = "--";
	    datesP[2] = "--";  
	    };
	dataG = Array.concat(data,datesP);
	
	return dataG;		
};


function Print_Img_data(Acelerator,date,RTImageLabel) {
	//Show the information of the test from which the image is taken.
	//there are two variants:
	//* Test 1.1 Picket Fence RapidArc
	//* Test 1.2 Picket Fence Error
	
	if (RTImageLabel==" MV_187_1a ")
	{
	   print("Test 1.1 Picket Fence RapidArc");
	   }
;
	else {
	    if (RTImageLabel==" MV_62_1a"){
	      print("Test 1.2 Picket Fence Error");
	      };
	    else {
	      print("Otra prueba"); 
	     }
;
	}
;
	print("Acelerator: "+Acelerator);print("date of the study analysed: "+date[5]+"/"+date[4]+"/"+date[3]);


};

function fix_rotation(x) { 
    //Rotating the image to correct tilt angle
	if (x==" MV_187_1a "){
		//Image without intentional errors
		run("Rotate... ", "angle=-"+0.1+" grid=1 interpolation=Bilinear"); 	
	};
	else {
		//Image with intentional errors
		run("Rotate... ", "angle=-"+0.13+" grid=1 interpolation=Bilinear"); 
	};
};

//********************* functions for drawing on images  **********************

function draw_rectangle(color, x, y, width, height) {
	//Draws a rectangle, where (x,y) specifies the upper left corner.
	//Used to fill in the error in the sheet.	
    makeRectangle(x, y,width,height,3);
	run("Add Selection...", "stroke="+color);	
};

function draw_line(color, x0, y0, x1, y1) {
	//To draw the lines in the figure
	makeLine(x0, y0, x1, y1);
	run("Add Selection...", "stroke="+color);	

};

function draw_center(values_595, dif_56_mm, tolerance) { 
	//Draw the centres and edges of the collimator parts for each collimator shot.
	//Draw subpixel lines by subtracting 0.5 from the desired position.
    ini = 3;
	//1 cm strips (the first 12 and the last 12)
	for (leaf = 0; leaf < 56; leaf++) {
		if (leaf < 12 ) {

			big_leaves_vicinity = Array.slice(values_595,ini,ini+14);
			Array.getStatistics(big_leaves_vicinity, min, max, mean, stdDev);
			draw_line("red",mean-0.5,ini-0.5,mean-0.5,ini+9.5);
			draw_line("magenta",0,ini-2.5,n,ini-2.5);
						
			//highlighting error dif_56_mm < tolerance
			if (dif_56_mm[leaf]>tolerance) {
				draw_rectangle("blue", mean-(tolerance*3)-1.5,ini-1.5,(3*tolerance*3)+1.5, 13.5);		
			};
			ini += 15;		
			//correction of the transition from large to small leaves
			if (leaf==11) {
				ini = ini - 2;				
			};						
		};
		
		if (11 < leaf && leaf < 44){

			small_leaves_vicinity = Array.slice(values_595,ini,ini+7);
			Array.getStatistics(small_leaves_vicinity, min, max, mean, stdDev);		
			draw_line("red",(mean)-0.5,ini-0.5,(mean)-0.5,ini+3.5);
			draw_line("magenta",0,ini-2.5,n,ini-2.5);
						
			//highlighting error dif_56_mm > tolerance
			if (dif_56_mm[leaf]>tolerance) {
				draw_rectangle("blue", mean-(tolerance*3)-1.5,ini-1.5,(3*tolerance*3)+1.5, 6.5); 
			}
			ini += 7.5;
		};
		
	  if (leaf > 43) {

		 big_leaves_vicinity = Array.slice(values_595,ini,ini+14);
		 Array.getStatistics(big_leaves_vicinity, min, max, mean, stdDev);
		 draw_line("red",(mean)-0.5,ini-0.5,(mean)-0.5,ini+9.5);
		 draw_line("magenta",0,ini-2.5,n,ini-2.5);
		
		 //highlighting error dif_56_mm > tolerance
		 if (dif_56_mm[leaf]>tolerance) {
		 	draw_rectangle("blue", mean-(tolerance*3)-1.5,ini-1.5,(3*tolerance*3)+1.5 , 13.5);	
		};
		
		ini += 15;
	  };
   };
};

//********************* calculation functions *******************************

function gaussian_centre(vicinity) { 
	//function to determine the Gaussian centre
	//receives as input the neighbourhood of values 
	X = newArray(lengthOf(vicinity));
	
	for (i = 0; i < lengthOf(vicinity); i++) {
		    	X[i]=i;
		    	};
		    	
    Fit.doFit("Gaussian", X, vicinity);  //gaussian fitting      
    x_centre = Fit.p(2); //obtaining the gaussian centre
    
    return x_centre   
};
    
 
function convert_to_56(values_595,n) {   
	//to convert from the 595 pixels to 56 values corresponding to the number of sheets
	//the values by which n is divided were determined using the pixel/distance conversion of the sample test images. 
	//the sample test images
	 
    valores56 = newArray(56);
	ini = 3;
	
	//1 cm sheets the first 12 and the last 12
	//the sum values are to calibrate according to the pixel-cm correpondence.
	for (leaf = 0; leaf < 56; leaf++) {
		if (leaf < 12 ) {
			big_leaves_vicinity = Array.slice(values_595,ini,ini+10);
			Array.getStatistics(big_leaves_vicinity, min, max, mean, stdDev);		
			valores56[leaf]=mean;
			ini += 15;
				
		    if (leaf==11) {
			       ini = ini - 2;
		}						
		};
		
		if (11 < leaf && leaf < 44){
			small_leaves_vicinity = Array.slice(values_595,ini,ini+4);
			Array.getStatistics(small_leaves_vicinity, min, max, mean, stdDev);		
			valores56[leaf]=mean;
			ini +=7.5; 
			};
			
		if (leaf > 43) {
			big_leaves_vicinity = Array.slice(values_595,ini,ini+10);
			Array.getStatistics(big_leaves_vicinity, min, max, mean, stdDev);		
			valores56[leaf]=mean;
			ini += 14.5; 
		};

	};
	
	return valores56;
	
};

//********************* Graphs  **********************

function plotting(L,tolerance) { 

   //Graph of the differences between the centre of the gaussisna
   //and the max. intensity for each of the 56 leaves
	
   tol = newArray(lengthOf(L)+20);    
   tol2 = newArray(lengthOf(L)+20); 
   Array.fill(tol, tolerance);
   Array.fill(tol2, tolerance+0.25);
   Array.getStatistics(dif_56_mm, min, max);
   Plot.create("Positioning error of the 56 leaves", "N. de leaf", "Error [mm]");
   Plot.setLimits(2, L[lengthOf(L)-1]+1, min, max+0.1)
   Plot.setFontSize(18);
   Plot.setLineWidth(2);
   Plot.setColor("blue","#bbbbff");
   Plot.add("separated bar",L,Array.reverse(dif_56_mm)); //due to the fact that the lamellae are nested from the bottom up.
   Plot.setColor("black", "#000000");
   indexCode = "code: setFont('sanserif',10*s,'bold anti');drawString(d2s(i+3, 0),x-4*s,y-2*s);";
   Plot.add(indexCode,L,dif_56_mm);
   Plot.setColor("magenta");
   a=newArray(1,2);
   b=newArray(lengthOf(L)+3,lengthOf(L)+4);
   L=Array.concat(a,L);
   L=Array.concat(L,b);
   Plot.add("line",L,tol);
   Plot.setColor("red", "#ff0000");
   Plot.add("line",L,tol2);
   Plot.show()
	
};

//********************************* Main ***************************************************

close("*")
print("\\Clear");
print("Test 1.0.0 QA_Picket Fence");



//Selecting the work folder
title = "Open";
msg = "Select the folder where the test image\n is located \"Picket Fence\" Band test" //"Seleccionar la carpeta donde se encuentre la imagen\n de la prueba \"Picket Fence\" Prueba de bandas";
waitForUser(title, msg);
dir = getDirectory("Select the Folder");
list=getFileList(dir);
l=list.length


//Automatically select the first image contained in the work folder
path=dir+list[0];open(path);

//stores the names of all items in the folder
name = File.getName(path); //gets the value of the image name

data = newArray(6);
data=get_DICOM_data(); 


//duplicate the image and work with the duplicate
run("Duplicate...", "title=[ ROI1.dcm]");


//showing image characteristics
Print_Img_data(data[0],data,data[1]); 

//invert image if this is taken on a white background, I get the corner values
X_00=getPixel(0, 0);
X_01=getPixel(0, data[2]-1);
X_10=getPixel(data[2]-1, 0);
X_11=getPixel(data[2]-1, data[2]-1);

//average of these values
prom=(X_00 + X_01 + X_10 + X_11)/4;
getStatistics(area, mean, min, max, std, histogram);

//Tf the corner values are higher than the average of the image I invert it
if (prom > mean ) {
	run("Invert");
};

//Angle correction
fix_rotation(data[1]); 

//cropping the area of interest, square with side half the image size
run("Specify...", "width="+data[2]/2+" height="+data[2]/2+" x="+data[2]/2+" y="+data[2]/2+" constrain centered");
run("Crop");

//processing the image
run("Median...", "radius=2"); //removing random noise
saveAs("Tiff", getDirectory("temp")+"tmp_cropped.tif");	//saving the image to come back to it later
run("Enhance Contrast...", "saturated=0.5");//increasing contrast

setBatchMode(true);
run("Measure");
close("Results");
run("Duplicate...", " "); 
run("Divide...", "value="+max);
;

//error tolerance to detect, default 0.25mm
Dialog.create("Seleccione la tolerance [mm]");
Dialog.addSlider("tolerance [mm]:", 0, 2, 0.25);
Dialog.show();
tolerance = Dialog.getNumber();

//Storing the image data in an array
n = round(data[2]/2);

//Half the image size 595 pixels
Data_Image = newArray(n*n);

//Total image pixels 595*595
Data_Image_Row = newArray(n);
max_c = newArray;
max_c_gauss = newArray;
max_c_a_gap = newArray;
ave_c_gap = newArray;
dif = newArray();

//moves through each pixel of the image starting from the top left corner in 
//horizontal movements
for (i=0;i<n;i++) {
	for (j=0;j<n;j++){
		Data_Image[(n*i)+j]= getPixel(j,i);	// All values of image n*n are stored.	
		Data_Image_Row[j]= getPixel(j,i); //The values of the current row (row number i) are stored.
		};
	
		max_Locs_Rows= Array.findMaxima(Data_Image_Row, 0.1); //Find the maximum values of row i
		max_Locs_Rows=Array.sort(max_Locs_Rows); //Sort them from smallest to largest or left to right		
		
	if (i==0) {
		Nume_Lineas_H = lengthOf(max_Locs_Rows); //Number of maxima in the first row, to determine how many maxi arrays 
			                                     //I have to create	
	     };
	    
		dif[i] = 1; //iniciation
		
	//Working for one row at a time     
	for (t = 0; t < Nume_Lineas_H; t++) {
		
		max_c[t+i*Nume_Lineas_H]=max_Locs_Rows[t]; //array with all the pisitions of the maxima 	     	
	     	     
	    //vicinity
	    vicinity = Array.slice(Data_Image_Row,max_Locs_Rows[t]-15,max_Locs_Rows[t]+15);		//(n/40)     		     
	    Array.getStatistics(vicinity, min, max, mean, stdDev);
	    //Almaceno the centres of the Gaussians for each gap
	    max_c_gauss[t+i*Nume_Lineas_H] = max_Locs_Rows[t]-15+gaussian_centre(vicinity); 	

        };	
	
};	

//converting from pixels to mm, I reduce the matrix from 595 to 56 values

// looking for the centre and the real boundaries of each gap
max_c_c= newArray();
max_c_c = Array.sort(Array.copy(max_c)); // this should be done to avoid reference to existing data.
max_c_gauss_sorted = newArray();


//correctly ordering the values of centres
for (t = 0; t < Nume_Lineas_H; t++) {
	for (i = 0; i < n; i++) {
		max_c_gauss_sorted[i+t*n] = max_c_gauss[t+(i*Nume_Lineas_H)];
	};
};


close();
setBatchMode(false);

for (t = 0; t < Nume_Lineas_H; t++) {
	//Stripes are drawn based on setting
	max_c_a_gap = Array.slice(max_c_gauss_sorted,t*n,(t+1)*n); //in each cycle, the x's of the max intensity are obtained.
	Array.getStatistics(max_c_a_gap, min, max, mean, stdDev);
	ave_c_gap = (mean);
	draw_line("green",ave_c_gap-(tolerance*3)-0.5,0,ave_c_gap-(tolerance*3)-0.5,n); // because 1 mm equals ~3 pixels  
	draw_line("green",ave_c_gap+(tolerance*3)-0.5,0,ave_c_gap+(tolerance*3)-0.5,n); // 
	

	for (i = 0; i < n; i++) {
		//Storing the dif for a t band
		dif[i+t*n]=Math.abs(max_c[t+i*(Nume_Lineas_H)] - mean); 
	};
	Overlay.show;		
}

//average the difference for each row i.e. average at a time as many values as there are slots.
ave_dif = newArray();
temp_dif = newArray(Nume_Lineas_H);

for (i = 0; i < n; i++) {
	for (t = 0; t < Nume_Lineas_H; t++) {
		temp_dif[t] = dif[t*n+i];		
	};
	Array.getStatistics(temp_dif, min, max, mean, stdDev);
	ave_dif[i]=mean;
};

//convert the difference in pixels to mm
dif_56 = convert_to_56(ave_dif,n);
dif_56_mm = newArray;


for (i = 0; i < lengthOf(dif_56); i++) {
	dif_56_mm[i]= dif_56[i]*0.336;
};

// a variable is created to plot the number of the sheets correctly
L = Array.getSequence(59);
for (i = 0; i < 3; i++) {
	L = Array.deleteIndex(L, 0);
};



for (t = 0; t < Nume_Lineas_H; t++) {
	// centres are plotted according to the average Gaussian fit for each band
	max_c_a_gap_int = Array.slice(max_c_gauss_sorted,t*n,(t+1)*n);
	draw_center(max_c_a_gap_int,dif_56_mm, tolerance);	
	Overlay.show;
}

plotting(L,tolerance);

//tabla
Table.create("Measurements of displacements (errors) by leaf") 
Table.setColumn("leaf", L) 
Table.setColumn("Error[mm]",dif_56_mm) 


//resultados
print("");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("Date of the test: "+ dayOfMonth +"/"+ (month+1)+"/"+year);
print("Time of the test: "+ hour +":"+ minute+":"+second);
print("");



//Salvando los resultados
val=getBoolean("Do you want to store the results?");
if (val==1) {
	dir2 = getDirectory("Select folder to save the results");
	selectWindow("Measurements of displacements (errors) by leaf");  //select Log-window
	saveAs("Text", dir2+"Picket Fence"+"_"+dayOfMonth +"-"+ (month+1)+"-"+year+".txt");
	saveAs("Text", dir2+"Picket Fence"+"_"+dayOfMonth +"-"+ (month+1)+"-"+year+".xls");
	exit
	}

exit