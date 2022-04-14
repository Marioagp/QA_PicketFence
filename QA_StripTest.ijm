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
    
    function Dibuja_Circulo(color, lineWidth, x, y) {
    setColor(color);
    setLineWidth(lineWidth);
    Overlay.drawEllipse(x-1, y-1, 2, 2);
    }
    
    function Dibuja_Punto(color, lineWidth, x0, y0, x1, y1) {
    setColor(color);
    setLineWidth(lineWidth);
    Overlay.drawLine(x0, y0, x1, y1);
    }
    
    function encuntra_vecindad(valor_central, Arreglo) { 
    // function description
    valores_vecinos = newArray(30);// se toman solo 30 valores pq da el ancho perfecto
    // se obtienen los 30 valores con centro en valor_central
    for (i = 0; i < 30; i++) {
         valores_vecinos[i] = Arreglo [valor_central-15+i];    
    };
    return valores_vecinos;
    };
    
    function Gauss(desviacion_STD, media, x_valores) { 
    // Crea una campana de Gauss con una "media" y una "desviacion_STD"
    a = 1/(desviacion_STD*Math.sqrt(2*PI)); 
    Nume = lengthOf(x_valores) ; 
    gauss_valores = newArray(Nume);    
    for (i = 0; i < Nume; i++) {
    	gauss_valores[i] = a*exp(-(Math.pow(x_valores[i]-media,2))/(2*Math.pow(desviacion_STD,2)));    	
    };

    
    return gauss_valores;
    
    };

   //******************************************************************************************************

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
	run("Median...", "radius=2");
	saveAs("Tiff", getDirectory("temp")+"tmp_cropped.tif");	// saves image to revert to later
    run("Enhance Contrast...", "saturated=0.5");// equalize");
    //run("Find Edges");

	// Almacenando los datos de la imagen en un array
	n = tamanodelaImag/2;
	ValoresImg = newArray(n*n);
	ValoresImg_Filas = newArray(n);
	max_1 = newArray(n);
	est_1_1 = newArray(n);
	est_2_1 = newArray(n);
	est_3_1 = newArray(n);
	est_4_1 = newArray(n);
	prod = newArray(n);


	for (i=0;i<n;i++) {
		for (j=0;j<n;j++){
			ValoresImg[(n*i)+j]= getPixel(j,i);		
			ValoresImg_Filas[j]= getPixel(j,i);	
			};
			
			maxLocs_Filas= Array.findMaxima(ValoresImg_Filas, 0.01);//encuantra los valores maximos de la fila i
			maxLocs_Filas=Array.sort(maxLocs_Filas);//los ordeno de menor a mayor o izq a derech
			max_1[i]= maxLocs_Filas[0]; //para plotear despues y comprobar
			
			
			
		if (i==0) {
			Nume_Lineas_H = lengthOf(maxLocs_Filas); //Numero de maximos en la primera fila, para determiar cuatos arreglos de maxi 
				                                     //tengo que crear	
		     };
		     
			prod[i] = 1; // inicializacion en uo para la opracion depues 
		
			
		     //Gaficar los maximos encontrados para cada franja
		for (t = 0; t < Nume_Lineas_H; t++) {
		     Dibuja_Punto("red",1,maxLocs_Filas[t],i,maxLocs_Filas[t],i); //ValoresImg_Filas[maxLocs_Filas[0]]
		     
		     // probando multiplicar cada maximo en cada fila para graficar depues y ver si da buenos resultados
		     prod[i] *= maxLocs_Filas[t] ;//mover esto al siguiente for, ahorro de memoria
		     
		     // vecindad
		     vencindad = encuntra_vecindad(maxLocs_Filas[t],ValoresImg_Filas);
		     Array.getStatistics(vencindad, min, max, mean, stdDev);
		     Overlay.show;
		     
		     		
	         };
			
			
	};
	
	
	
	
	
	// Graficar el producto
	Plot.create("Producto", "X-axis Label", "Y-axis Label", prod)
	Array.show(prod);
	
	a = newArray(30);
	w= -15;
	for (i = 0; i < 30; i++) {
		a [i] = w;
		w++;
	}
	
	

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
