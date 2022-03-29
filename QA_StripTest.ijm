	//AREA DE FUNCIONES (PUEDE ESTAR AL FINAL)
	function Datos_de_la_Imag(Acelerador,fecha,RTImageLabel) {
	// Mostrar la informacion de la prueba de la cual proviene la imagen
	if (RTImageLabel==" MV_187_1a")
	{
	   print("Test 1.1 Picket Fence RapidArc");
	}
	else {
	    if (RTImageLabel==" MV_62_1a"){
	      print("Test 1.2 Picket Fence Error");
	     } 
	    else {
	      exit("ELEGIR UNA IMAGEN PROVENIENTE DE LAS PRUEBAS: Test 1.1 Picket Fence RapidArc o Test 1.2 Picket Fence Error"); 
	     }
	}


	print(""); print("Acelerador: "+Acelerador); print("Fecha del estudio: "+ fecha);print("");

	print(" - - - - - - - - - - - - - - - - - - - - - - ");
	};
	
	
	
	function Resalta_A_Error(color, lineWidth, x, y) {
    setColor(color);
    setLineWidth(lineWidth);
    Overlay.drawEllipse(x, y, 20, 20);
    }



//main()
print("\\Clear");
print("Prueba 1.0.0 QA_StripTest");
print("");


//seleccion de la carpeta de trabajo
title = "Abrir";
msg = "Seleccionar la carpeta donde se encuentren las imágenes\n de la prueba \"Strip Test\" Prueba de bandas";
waitForUser(title, msg);
dir = getDirectory("Selecciona Carpeta");
list=getFileList(dir);
l=list.length
 

//seleccionar la primera imagen de la carpeta
path=dir+list[0];open(path);
name = File.getName(path); //obtiene el valor del nombre de la imagen

//obtiene datos de la imagen DICOM
Acelerador=getInfo("0008,1010");
fecha=getInfo("0008,0022");	
RTImageLabel = getInfo("3002,0002"); // para identificar si es una prueba con o sin ERROR INTENCIONADO 
tamanodelaImag=getInfo("0028,0011");

tamanodelaImag=parseInt(tamanodelaImag) // String to number

//mid_sizeofimage= 50+sizeofimage/2;
//run("Specify...", "width="+mid_sizeofimage+" height="+mid_sizeofimage+" x="+mid_sizeofimage+" y="+mid_sizeofimage+" constrain centered");

	//RECORTANDO LA IMAGEN SE USA LA UN CUADRADO DE MITAD DE AREA
	run("Specify...", "width="+tamanodelaImag/2+" height="+tamanodelaImag/2+" x="+tamanodelaImag/2+" y="+tamanodelaImag/2+" constrain centered");
	run("Crop");
	saveAs("Tiff", getDirectory("temp")+"tmp_cropped.tif");	// saves image to revert to later


	// Almacenando los datos de la imagen en un array
	n = tamanodelaImag/2;
	ValoresImg = newArray(n*n);

	for (i=0;i<n;i++) {
		for (j=0;j<n;j++){
			ValoresImg[(n*i)+j]= getPixel(j,i);			
			};
	}

	//Array.show(ValoresImg)

	//Dibujar las areas determinadas como errores
	x0=100;
	x1=200;
	y0=100;
	y1=200;
	
	Resalta_A_Error("red",2,x0,y0);
	Resalta_A_Error("red",2,x1,y1);
	Overlay.show;
	
	//makeSelection("freehand", newArray(100,100,125,125,100), newArray(100,125,125,100,100));
	//setKeyDown("shift");
	//makeSelection("freehand", newArray(200,200,225,225,200), newArray(200,225,225,200,200));

	//Plot.create("Title", "X-axis Label", "Y-axis Label",ValoresImg)

	Datos_de_la_Imag(Acelerador,fecha,RTImageLabel);
