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
    
    function Dibuja_Punto(color, lineWidth, x, y) {
    setColor(color);
    setLineWidth(lineWidth);
    Overlay.drawEllipse(x-1, y-1, 2, 2);
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
    run("Enhance Contrast...", "saturated=0.5");// equalize");
    //run("Find Edges");

	// Almacenando los datos de la imagen en un array
	n = tamanodelaImag/2;
	ValoresImg = newArray(n*n);
	ValoresImg_Filas = newArray(n);
	max_1 = newArray(n);
	max_2 = newArray(n);
	max_3 = newArray(n);
	max_4 = newArray(n);
	max_5 = newArray(n);
	max_6 = newArray(n);

	for (i=0;i<n;i++) {
		for (j=0;j<n;j++){
			ValoresImg[(n*i)+j]= getPixel(j,i);		
			ValoresImg_Filas[j]= getPixel(j,i);	
			};
			maxLocs_Filas= Array.findMaxima(ValoresImg_Filas, 0.01);
			maxLocs_Filas=Array.sort(maxLocs_Filas);
			max_1[i]= maxLocs_Filas[0];
			
			//if (i==150) {
				//Array.show(maxLocs_Filas);
				//Plot.create("Title", "X-axis Label", "Y-axis Label", ValoresImg_Filas) 
				Dibuja_Punto("red",1,maxLocs_Filas[0],i);//ValoresImg_Filas[maxLocs_Filas[0]]
	            //Dibuja_Punto("red",1,maxLocs_Filas[1],i);
	            //Dibuja_Punto("red",1,maxLocs_Filas[2],i);
	            //Dibuja_Punto("red",1,maxLocs_Filas[3],i);
	            //Dibuja_Punto("red",1,maxLocs_Filas[4],i);
	            //Dibuja_Punto("red",1,maxLocs_Filas[5],i);
	            Overlay.show;
			//};

	};
	Plot.create("Title", "X-axis Label", "Y-axis Label", max_1)
	Array.show(max_1);

	//Array.show(ValoresImg)

	//Dibujar las areas determinadas como errores
	x0=100;
	x1=200;
	y0=100;
	y1=200;
	
	//Resalta_A_Error("red",2,x0,y0);
	//Resalta_A_Error("red",2,x1,y1);
	//Overlay.show;
	
	//makeSelection("freehand", newArray(100,100,125,125,100), newArray(100,125,125,100,100));
	//setKeyDown("shift");
	//makeSelection("freehand", newArray(200,200,225,225,200), newArray(200,225,225,200,200));

	//Plot.create("Title", "X-axis Label", "Y-axis Label",ValoresImg)

	Datos_de_la_Imag(Acelerador,fecha,RTImageLabel);
