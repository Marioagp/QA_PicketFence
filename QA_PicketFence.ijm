//*********************funciones que obtienen la información de la imágenes DICOM  **********************

function obtener_datos_DICOM() { 
    //obtiene datos de la imagen DICOM
    datos = newArray(3);
    
    Acelerador=getInfo("0008,1010"); // Obtiene información del Acelerador	
	RTImageLabel = getInfo("3002,0002"); // Para identificar si es una prueba con o sin ERROR INTENCIONADO
	fecha=getInfo("0008,0022");	     // Obtiene la fecha de la prueba

	tamanodelaImag=getWidth(); // Obtiene el tamaño de la imagen
	
	//Almacena los valores para luego devolverlos en un array
	datos[0]=Acelerador;
	datos[1]=RTImageLabel;
	datos[2]=tamanodelaImag;
	
	if(fecha != "")
		{
		date = newArray(3);
	    date[0] = substring(fecha, 1, 5);
	    date[1] = substring(fecha, 5, 7);
	    date[2] = substring(fecha, 7, 9);  	
	    };
    else {
	    date = newArray(3);
	    date[0] = "--";
	    date[1] = "--";
	    date[2] = "--";  
	    };
	datosG = Array.concat(datos,date);
	
	return datosG;		
};


function datos_de_la_Imag(Acelerador,fecha,RTImageLabel) {
	// Mostrar la informacion de la prueba de la cual proviene la imagen
	//existen dos variantes:
	//* Test 1.1 Picket Fence RapidArc
	//* Test 1.2 Picket Fence Error
	
	if (RTImageLabel==" MV_187_1a ")
	{
	   print("Test 1.1 Picket Fence RapidArc");
	   };
	else {
	    if (RTImageLabel==" MV_62_1a"){
	      print("Test 1.2 Picket Fence Error");
	      };
	    else {
	      print("Otra prueba"); 
	     };
	};
	print("Acelerador: "+Acelerador);print("Fecha del estudio analizado: "+fecha[5]+"/"+fecha[4]+"/"+fecha[3]);

};

function corrige_angulo(x) { 
    //Rotando la imagen para corregir ángulo de inclinación
	if (x==" MV_187_1a "){
		//Imagen sin errores intencionados
		run("Rotate... ", "angle=-"+0.1+" grid=1 interpolation=Bilinear"); 	
	};
	else {
		//Imagen con error intencionados
		run("Rotate... ", "angle=-"+0.13+" grid=1 interpolation=Bilinear"); 
	};
};

//*********************funciones que dibujan sobre las imágenes  **********************

function dibuja_rectangulo(color, x, y, width, height) {
	//Dibuja un rectangulo, donde (x,y) especifica la esquina superior izquierda.
	//Usado para realtar Error en la láminas	
    makeRectangle(x, y,width,height,3);
	run("Add Selection...", "stroke="+color);	
};

function dibuja_linea(color, x0, y0, x1, y1) {
	//Para dibujar las líneas en la figura
	makeLine(x0, y0, x1, y1);
	run("Add Selection...", "stroke="+color);	

};

function dibuja_centros(valores595, dif_56_mm,tolerancia) { 
	//Dibuja los centro y los bordes de las piezas del colimador en cada disparo del colimador
	//Para dibujar lineas subpixeles hay que restar 0.5 de la posición desada
    ini = 3;
	//laminas de 1 cm las 12 primeras y las 12 ultimas
	for (lamina = 0; lamina < 56; lamina++) {
		if (lamina < 12 ) {

			vecindad_laminaGra = Array.slice(valores595,ini,ini+14);
			Array.getStatistics(vecindad_laminaGra, min, max, mean, stdDev);
			dibuja_linea("red",mean-0.5,ini-0.5,mean-0.5,ini+9.5);
			dibuja_linea("magenta",0,ini-2.5,n,ini-2.5);
						
			//resaltando el error dif_56_mm < tolerancia
			if (dif_56_mm[lamina]>tolerancia) {
				dibuja_rectangulo("blue", mean-(tolerancia*3)-1.5,ini-1.5,(3*tolerancia*3)+1.5, 13.5);		
			};
			ini += 15;		
			//corrección del paso de las laminas grandes a las pequeñas
			if (lamina==11) {
				ini = ini - 2;				
			};						
		};
		
		if (11 < lamina && lamina < 44){

			vecindad_laminaPeq = Array.slice(valores595,ini,ini+7);
			Array.getStatistics(vecindad_laminaPeq, min, max, mean, stdDev);		
			dibuja_linea("red",(mean)-0.5,ini-0.5,(mean)-0.5,ini+3.5);
			dibuja_linea("magenta",0,ini-2.5,n,ini-2.5);
						
			//resaltando el error dif_56_mm > tolerancia
			if (dif_56_mm[lamina]>tolerancia) {
				dibuja_rectangulo("blue", mean-(tolerancia*3)-1.5,ini-1.5,(3*tolerancia*3)+1.5, 6.5); 
			}
			ini += 7.5;
		};
		
	  if (lamina > 43) {

		 vecindad_laminaGra = Array.slice(valores595,ini,ini+14);
		 Array.getStatistics(vecindad_laminaGra, min, max, mean, stdDev);
		 dibuja_linea("red",(mean)-0.5,ini-0.5,(mean)-0.5,ini+9.5);
		 dibuja_linea("magenta",0,ini-2.5,n,ini-2.5);
		
		 //resaltando el error dif_56_mm > tolerancia
		 if (dif_56_mm[lamina]>tolerancia) {
		 	dibuja_rectangulo("blue", mean-(tolerancia*3)-1.5,ini-1.5,(3*tolerancia*3)+1.5 , 13.5);	
		};
		
		ini += 15;
	  };
   };
};

//*********************funciones de calculo de la información *******************************

function centro_gausiana(vecindad) { 
	//función para determinar el centro gausiano
	//recibe como entrada la vecindad de valores 
	X = newArray(lengthOf(vecindad));
	
	for (i = 0; i < lengthOf(vecindad); i++) {
		    	X[i]=i;
		    	};
		    	
    Fit.doFit("Gaussian", X, vecindad);  //ajuste gausiano      
    x_centro = Fit.p(2); //obtiene el centro de la curva gausiana
    
    return x_centro   
};
    
 
function convierte_56(valores595,n) {   
	//para convertir de lo 595 pixeles a 56 valores correspondietes a la cantidad de láminas
	//los valores por los cuales se divide n se determinaron usando la conversión pixel/distancia de 
	//las imágenes de las pruebas de muestra
	 
    valores56 = newArray(56);
	ini = 3;
	
	//láminas de 1 cm las 12 primeras y las 12 ultimas
	//los valores de suma son para calibrar segun la correpondencia pixel-cm
	for (lamina = 0; lamina < 56; lamina++) {
		if (lamina < 12 ) {
			vecindad_laminaGra = Array.slice(valores595,ini,ini+10);
			Array.getStatistics(vecindad_laminaGra, min, max, mean, stdDev);		
			valores56[lamina]=mean;
			ini += 15;
				
		    if (lamina==11) {
			       ini = ini - 2;
		}						
		};
		
		if (11 < lamina && lamina < 44){
			vecindad_laminaPeq = Array.slice(valores595,ini,ini+4);
			Array.getStatistics(vecindad_laminaPeq, min, max, mean, stdDev);		
			valores56[lamina]=mean;
			ini +=7.5; 
			};
			
		if (lamina > 43) {
			vecindad_laminaGra = Array.slice(valores595,ini,ini+10);
			Array.getStatistics(vecindad_laminaGra, min, max, mean, stdDev);		
			valores56[lamina]=mean;
			ini += 14.5; 
		};

	};
	
	return valores56;
	
};

//*********************funciones que muestran la información en las gráficas  **********************

function ploting(L,tolerancia) { 

   //Gráfica de las diferencias entre el centro de la gaussisna
   //y el max de intensidad por cada una de las 56 láminas
	
   tol = newArray(lengthOf(L)+20);    
   tol2 = newArray(lengthOf(L)+20); 
   Array.fill(tol, tolerancia);
   Array.fill(tol2, tolerancia+0.25);
   Array.getStatistics(dif_56_mm, min, max);
   Plot.create("Error de posicionamiento de las 56 laminas", "N. de lamina", "Error [mm]");
   Plot.setLimits(2, L[lengthOf(L)-1]+1, min, max+0.1)
   Plot.setFontSize(18);
   Plot.setLineWidth(2);
   Plot.setColor("blue","#bbbbff");
   Plot.add("separated bar",L,Array.reverse(dif_56_mm));//debido a que las laminas estan nuemradas de abajo hacia arriba
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

//********************************* Ejecución del programa ***************************************************

close("*")
print("\\Clear");
print("Prueba 1.0.0 QA_Picket Fence");



//seleccion de la carpeta de trabajo
title = "Abrir";
msg = "Seleccionar la carpeta donde se encuentre la imagen\n de la prueba \"Picket Fence\" Prueba de bandas";
waitForUser(title, msg);
dir = getDirectory("Selecciona Carpeta");
list=getFileList(dir);
l=list.length


//selecciona la primera imagen de la carpeta
path=dir+list[0];open(path);

//guarda los nombres de todos los elementos de la carpeta
name = File.getName(path); //obtiene el valor del nombre de la imagen

datos = newArray(6);
datos=obtener_datos_DICOM(); 


//duplica la imagen y trabajo con el duplicado
run("Duplicate...", "title=[ ROI1.dcm]");


//mostrando caracteristicas de la imagen
datos_de_la_Imag(datos[0],datos,datos[1]); 

//invertir imagen si es esta tomada en fondo blanco, obtengo los valores de las esquinas
X_00=getPixel(0, 0);
X_01=getPixel(0, datos[2]-1);
X_10=getPixel(datos[2]-1, 0);
X_11=getPixel(datos[2]-1, datos[2]-1);

//promedio de la estos valores
prom=(X_00 + X_01 + X_10 + X_11)/4;
getStatistics(area, mean, min, max, std, histogram);

//si los valores de las esquinas son mayores que el promedio de la imagen invierto
if (prom > mean ) {
	run("Invert");
};

//se corrige el ángulo
corrige_angulo(datos[1]); 

//recortando el área de interés, cuadrado con lado mitad del tamaño de la imagen
run("Specify...", "width="+datos[2]/2+" height="+datos[2]/2+" x="+datos[2]/2+" y="+datos[2]/2+" constrain centered");
run("Crop");

//procesado de la imagen
run("Median...", "radius=2"); //elimnado ruido aleatorio
saveAs("Tiff", getDirectory("temp")+"tmp_cropped.tif");	//guarda la imagen para volver a ella más tarde
run("Enhance Contrast...", "saturated=0.5");// aumenta el contraste

setBatchMode(true);
run("Measure");
close("Results");
run("Duplicate...", " "); 
run("Divide...", "value="+max);

//run("8-bit");

//Tolerancia de error a detectar, por defecto 0.25mm
Dialog.create("Seleccione la tolerancia [mm]");
Dialog.addSlider("Tolerancia [mm]:", 0, 2, 0.25);
Dialog.show();
tolerancia = Dialog.getNumber();

//Almacenando los datos de la imagen en un array
n = round(datos[2]/2);

//Mitad del tamaño de la imagen 595 pixeles
ValoresImg = newArray(n*n);

//Total de pixeles de la imagen 595*595
ValoresImg_Filas = newArray(n);
max_c = newArray;
max_c_gauss = newArray;
max_c_una_franja = newArray;
prom_c_franjas = newArray;
dif = newArray();

//se recorren cada uno de los pixeles de la imagen comenzando desde la esq izq superior en 
//movimientos horizontales
for (i=0;i<n;i++) {
	for (j=0;j<n;j++){
		ValoresImg[(n*i)+j]= getPixel(j,i);	//Se almacena todos los valores de imagem n*n	
		ValoresImg_Filas[j]= getPixel(j,i); //Se almacenan los valores de la fila en curso (número de fila i)
		};
	
		maxLocs_Filas= Array.findMaxima(ValoresImg_Filas, 0.1); //Encuentra los valores máximos de la fila i
		maxLocs_Filas=Array.sort(maxLocs_Filas); //Los ordeno de menor a mayor o izq a derecha		
		
	if (i==0) {
		Nume_Lineas_H = lengthOf(maxLocs_Filas); //Número de máximos en la primera fila, para determiar cuantos arreglos de maxi 
			                                     //tengo que crear	
	     };
	    
		dif[i] = 1; //inicialización
		
	//Trabajado para una fila	     
	for (t = 0; t < Nume_Lineas_H; t++) {
		
		max_c[t+i*Nume_Lineas_H]=maxLocs_Filas[t]; //array con todos las pisiciones de los máximos 	     	
	     	     
	    //Vecindad
	    vecindad = Array.slice(ValoresImg_Filas,maxLocs_Filas[t]-15,maxLocs_Filas[t]+15);		//(n/40)     		     
	    Array.getStatistics(vecindad, min, max, mean, stdDev);
	    //Almaceno los centros de las gausianas para cada franja
	    max_c_gauss[t+i*Nume_Lineas_H] = maxLocs_Filas[t]-15+centro_gausiana(vecindad); 	

        };	
	
};	

//convirtiendo de pixeles a mm, reduzco la matriz de 595 a 56 valores

// buscando el centro y los límites reales de las franjas
max_c_c= newArray();
max_c_c = Array.sort(Array.copy(max_c)); //hay que hacerlo así para evitar la referencia a los datos existentes
max_c_gauss_ordenado = newArray();
//max_c_gauss=Array.sort(max_c_gauss);

//ordenando correctamente los valores de centros
for (t = 0; t < Nume_Lineas_H; t++) {
	for (i = 0; i < n; i++) {
		max_c_gauss_ordenado[i+t*n] = max_c_gauss[t+(i*Nume_Lineas_H)];
	};
};


close();
setBatchMode(false);

for (t = 0; t < Nume_Lineas_H; t++) {
	//Se dibujan las franjas basados en ajuste
	max_c_una_franja = Array.slice(max_c_gauss_ordenado,t*n,(t+1)*n); //en cada ciclo se obtienen las x de los max de intensidad
	Array.getStatistics(max_c_una_franja, min, max, mean, stdDev);
	prom_c_franjas = (mean);
	dibuja_linea("green",prom_c_franjas-(tolerancia*3)-0.5,0,prom_c_franjas-(tolerancia*3)-0.5,n); // porque 1 mm equivale a ~3 pixeles  
	dibuja_linea("green",prom_c_franjas+(tolerancia*3)-0.5,0,prom_c_franjas+(tolerancia*3)-0.5,n); // 
	

	for (i = 0; i < n; i++) {
		//Almacendo la dif para una franja t
		dif[i+t*n]=Math.abs(max_c[t+i*(Nume_Lineas_H)] - mean); 
	};
	Overlay.show;		
}

//promedio la diferencia para cada fila es decir promedio a la vez tantos valores como franjas existan
prom_dif = newArray();
temp_dif = newArray(Nume_Lineas_H);

for (i = 0; i < n; i++) {
	for (t = 0; t < Nume_Lineas_H; t++) {
		temp_dif[t] = dif[t*n+i];		
	};
	Array.getStatistics(temp_dif, min, max, mean, stdDev);
	prom_dif[i]=mean;
};

//convertir a mm la diferencia en pixeles
dif_56 = convierte_56(prom_dif,n);
dif_56_mm = newArray;


for (i = 0; i < lengthOf(dif_56); i++) {
	dif_56_mm[i]= dif_56[i]*0.336;
};

//se crea una variable para graficar el número de las láminas correctamente
L = Array.getSequence(59);
for (i = 0; i < 3; i++) {
	L = Array.deleteIndex(L, 0);
};



for (t = 0; t < Nume_Lineas_H; t++) {
	//se dibuja los centros según el promedio del ajuste gausiano para cada franja
	max_c_una_franja_int = Array.slice(max_c_gauss_ordenado,t*n,(t+1)*n);
	dibuja_centros(max_c_una_franja_int,dif_56_mm, tolerancia);	
	Overlay.show;
}

ploting(L,tolerancia);

//tabla
Table.create("Medidas de desplazamientos (errores) por laminas") 
Table.setColumn("Lamina", L) 
Table.setColumn("Error[mm]",dif_56_mm) 


//resultados
print("");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("Fecha de la prueba: "+ dayOfMonth +"/"+ (month+1)+"/"+year);
print("Hora de la prueba: "+ hour +":"+ minute+":"+second);
print("");



//Salvando los resultados
val=getBoolean("Guardar las medidas?");
if (val==1) {
	dir2 = getDirectory("Selecciona carpeta para guardar los resultados");
	selectWindow("Medidas de desplazamientos (errores) por laminas");  //select Log-window
	saveAs("Text", dir2+"Picket Fence"+"_"+dayOfMonth +"-"+ (month+1)+"-"+year+".txt");
	saveAs("Text", dir2+"Picket Fence"+"_"+dayOfMonth +"-"+ (month+1)+"-"+year+".xls");
	exit
	}

exit

