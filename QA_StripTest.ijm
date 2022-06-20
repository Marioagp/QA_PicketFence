//AREA DE FUNCIONES

function obtener_datos_DICOM() { 
//obtiene datos de la imagen DICOM
    datos = newArray(4);
	Acelerador=getInfo("0008,1010"); // Obtiene información del Acelerador
	fecha=getInfo("0008,0022");	     // Obtiene la fecha de la prueba
	RTImageLabel = getInfo("3002,0002"); // para identificar si es una prueba con o sin ERROR INTENCIONADO 
	tamanodelaImag=getInfo("0028,0011"); // Obtiene el tamaño de la imagen
	tamanodelaImag=parseInt(tamanodelaImag) // convierte de String to int
	
	// almacena los valores para luego devolverlos en un array
	datos[0]=Acelerador;
	datos[1]=fecha;
	datos[2]=RTImageLabel;
	datos[3]=tamanodelaImag;
	
	// muetra los datos de la prueba analizada
	Array.print(datos);
	
	return datos;	
};


function Datos_de_la_Imag(Acelerador,fecha,RTImageLabel) {
// Mostrar la informacion de la prueba de la cual proviene la imagen

if (RTImageLabel==" MV_187_1a ")
{
   print("Test 1.1 Picket Fence RapidArc");
   };
else {
    if (RTImageLabel==" MV_62_1a"){
      print("Test 1.2 Picket Fence Error");
      };
    else {
      exit("ELEGIR UNA IMAGEN PROVENIENTE DE LAS PRUEBAS: Test 1.1 Picket Fence RapidArc o Test 1.2 Picket Fence Error"); 
     };
};
print(""); print("Acelerador: "+Acelerador); print("Fecha del estudio: "+ fecha);print("");
print(" - - - - - - - - - - - - - - - - - - - - - - ");

};

function corrige_angulo(x) { 
//Rotando la imagen para corregir angulo de defasaje
	if (x==" MV_187_1a "){
		//Imagen sin errores intencionados (determinado empíricamente)
		run("Rotate... ", "angle=-"+0.1+" grid=1 interpolation=Bilinear"); 	
	};
	else {
		//Imagen con error intencionados (determinado empíricamente)
		run("Rotate... ", "angle=-"+0.13+" grid=1 interpolation=Bilinear"); 
	};
};


function Dibuja_rectangulo(color, lineWidth, x, y, width, height) {
	//Dibuja un rectángulo, donde (x,y) especifica la esquina superior izquierda.
	//Usado para realtar Error en la lámina	
		setColor(color);
		setLineWidth(lineWidth);
		Overlay.drawRect(x, y, width, height);
};

function Dibuja_Punto(color, lineWidth, x0, y0, x1, y1) {
	//Para dibujar las líneas en la figura
		setColor(color);
		setLineWidth(lineWidth);
		Overlay.drawLine(x0, y0, x1, y1);		
};

function Centro_Gaussiana(vecindad) { 
		//Función para determinar el cetro gausiano
		//recibe como entrada la vecindad de valores 
X = newArray(lengthOf(vecindad));
for (i = 0; i < lengthOf(vecindad); i++) {
	    	X[i]=i;
	    	};
    Fit.doFit("Gaussian", X, vecindad);  //ajuste gaussiano      
    x_centro = Fit.p(2); //obtine el centro de la curva gaussiana
    return x_centro   
    };
    
 
function Centro_centroide(vecindad) { 
		//Función para determinar el cetro gausiano
		//recibe como entrada la vecindad de valores
		
		den=0;
		num=0;
		X = newArray(lengthOf(vecindad));
		for (i = 0; i < lengthOf(vecindad); i++) {
			    	X[i]=i;
			    	};
	    for (i = 0; i < lengthOf(vecindad); i++) {
	    	num+=X[i]*vecindad[i];
	    };
	    for (i = 0; i < lengthOf(vecindad); i++) {
	    	den+=vecindad[i];
	    };
	    
	    x_centro = num/den;

		return x_centro   
 };
 
 
function skewness(datos,mean,StDv) { 
		
		n = lengthOf(datos);
		skewnees_n=0;
		for (i = 0; i < n; i++) {
			skewnees_n+=Math.pow((datos[i]-mean), 3);
		} 
		for (i = 0; i < n; i++) {
			skewnees_d+=Math.pow((datos[i]-mean), 2);
		} 
		sk =   skewnees_n * (1/n) * (1/(Math.pow(Math.sqrt((1/n)*skewnees_d),3)));
	   return sk
};


function kurtosis(datos,mean,StDv) { 
		n = lengthOf(datos);
		for (i = 0; i < n; i++) {
			kurtosis_n+=Math.pow((datos[i]-mean), 4);
		};    
		for (i = 0; i < n; i++) {
			kurtosis_d+=Math.pow((datos[i]-mean), 2);
		};
     	 kt= ((1/n)*kurtosis_n)/(Math.pow((1/n)*kurtosis_d, 2));  
     	 return kt;
};

function cover595to56(valores595) {   
// para convertir de lo 595 pixeles a 56 valores correspondietes a la cantidad de leafs
    valores56 = newArray(56);
	ini = 4;
	//laminas de 1 cm las 12 primeras y las 12 ultimas
	// los vaslores de suma son para calibrar segun la correpondencia pixel-cm
	for (lamina = 0; lamina < 56; lamina++) {
		if (lamina < 12 ) {
			vecindad_laminaGra = Array.slice(valores595,ini,ini+14);
			Array.getStatistics(vecindad_laminaGra, min, max, mean, stdDev);		
			valores56[lamina]=mean;
			ini += 15;	
		    if (lamina==11) {
			       ini = ini -2;
		}						
		};
		
		if (11 < lamina && lamina < 44){
			vecindad_laminaPeq = Array.slice(valores595,ini,ini+7);
			Array.getStatistics(vecindad_laminaPeq, min, max, mean, stdDev);		
			valores56[lamina]=mean;
			ini +=7.5; 
			};
			
		if (lamina > 43) {
			vecindad_laminaGra = Array.slice(valores595,ini,ini+14);
			Array.getStatistics(vecindad_laminaGra, min, max, mean, stdDev);		
			valores56[lamina]=mean;
			ini +=14.5; 
		};

	};
	return valores56;
	
};

function dibuja_centros_y_gap(valores595, prod_56) { 
//Dibuja los centro y los bordes de las piezas del colimador en cada disparo del colimador
    ini = 4;
	//laminas de 1 cm las 12 primeras y las 12 ultimas
	for (lamina = 0; lamina < 56; lamina++) {
		if (lamina < 12 ) {
			vecindad_laminaGra = Array.slice(valores595,ini,ini+10);
			Array.getStatistics(vecindad_laminaGra, min, max, mean, stdDev);		
			Dibuja_Punto("red",1,(mean),ini,(mean),ini+10);
						
			//resaltando el error pod_56 < 0.97
			if (prod_56[lamina]<0.97) {
				Dibuja_rectangulo("blue", 1, mean-5,ini-2.5, 10, 14);			
			}
			ini += 15;	
			//correccion del paso de las laminas grandes a las chicas
			if (lamina==11) {
				ini = ini -2;
			}						
		};
		
		if (11 < lamina && lamina < 44){
			vecindad_laminaPeq = Array.slice(valores595,ini,ini+4);
			Array.getStatistics(vecindad_laminaPeq, min, max, mean, stdDev);		
			Dibuja_Punto("red",1,(mean),ini,(mean),ini+4);
						
			//resaltando el error pod_56 < 0.97
			if (prod_56[lamina]<0.97) {
				Dibuja_rectangulo("blue", 1, mean-5,ini-1.25, 10, 7); 
			}
			ini +=7.5; 
			};
			
		if (lamina > 43) {
			vecindad_laminaGra = Array.slice(valores595,ini,ini+10);
			Array.getStatistics(vecindad_laminaGra, min, max, mean, stdDev);		
			Dibuja_Punto("red",1,(mean),ini,(mean),ini+10);
			
			//resaltando el error pod_56 < 0.97
			if (prod_56[lamina]<0.97) {
				Dibuja_rectangulo("blue", 1, mean-5,ini-2.5, 10, 14);
				};
			ini +=14.5; 
		};
	};
};
//*********************funciones que muestran la informacion en graficas**********************
function ploting() {    //ARREGLAR PARA FACILITAR INTERPRETACION DEL USUARIO
	//Graficar el producto
	Plot.create("Producto", "X-axis Label", "Y-axis Label")
	Plot.add("line",prod);
	Plot.show()
	
	
	//grafica diferencia para linea igual a t	
	Plot.create("Diferencia", "X-axis Label", "Y-axis Label");
	Plot.add("line",prom_dif);
	Plot.show()

	//grafica de los proemdios por cada lamina 60 valores
	Plot.create("prod 56", "X-axis Label", "Y-axis Label");
	Plot.add("line",prod_56);
	Plot.add("separated bar",prod_56);
	Plot.show()
	
	//grafica de las diferencias entre el cetro de la gauss y el max de intensidad por cada lamina 60 valores
	Plot.create("Dif 56", "lamina", "diefencia en pixel");
	Plot.add("line",dif_56);
	Plot.add("separated bar",dif_56);
	Plot.show()
	
	
	//grafica de las diferencias entre el cetro de la gauss y el max de intensidad por cada lamina 60 valores
	Plot.create("Dif 56 mm", "lamina", "diferencia en mm");
	Plot.add("separated bar",dif_56_mm);
	Plot.show()
	
    //Graficar el skewness
	Plot.create("Skewness", "X-axis Label", "Y-axis Label");
	Plot.add("line", skewness_valo_1);
	Plot.show()
	
	//Graficar el kurtosis
	Plot.create("Kurtosis", "X-axis Label", "Y-axis Label");
	Plot.add("line", kurtosis_valo_1);
	Plot.show()

};



//******************************************************************************************************

//main()
close("*")
print("\\Clear");
print("Prueba 1.0.0 QA_StripTest");
print("");
//run("Close");

//seleccion de la carpeta de trabajo
title = "Abrir";
msg = "Seleccionar la carpeta donde se encuentre la imágen\n de la prueba \"Strip Test\" Prueba de bandas";
waitForUser(title, msg);
dir = getDirectory("Selecciona Carpeta");
list=getFileList(dir);
l=list.length


//selecciona la primera imagen de la carpeta
path=dir+list[0];open(path); //guarda los nombres de todos los elementos de la carpeta
name = File.getName(path); //obtiene el valor del nombre de la imagen

datos = newArray(4);
datos=obtener_datos_DICOM();


//duplica la imagen y trabajo con el duplicado
run("Duplicate...", "title=[ ROI1.dcm]");


//mostrando caracteristicas de la imagen
Datos_de_la_Imag(datos[0],datos[1],datos[2]);

//invertir imagen si es esta tomada en fondo blanco
//obtengo los valores de las esquinas
X_00=getPixel(0, 0);
X_01=getPixel(0, datos[3]-1);
X_10=getPixel(datos[3]-1, 0);
X_11=getPixel(datos[3]-1, datos[3]-1);
//promedio de la estos valores
prom=(X_00 + X_01 + X_10 + X_11)/4;
getStatistics(area, mean, min, max, std, histogram);
//si los valores de las esquinas son mayores que el promedio de la imagen invierto
if (prom > mean ) {
	run("Invert");
};

corrige_angulo(datos[2]);

//recoertando el area de interes, cuadrado con lado mitad del tamaño de la imagen

run("Specify...", "width="+datos[3]/2+" height="+datos[3]/2+" x="+datos[3]/2+" y="+datos[3]/2+" constrain centered");
run("Crop");
run("Median...", "radius=2"); //elimnado ruido aleatorio
saveAs("Tiff", getDirectory("temp")+"tmp_cropped.tif");	// guarda la imagen para volver a ella más tarde
run("Enhance Contrast...", "saturated=0.5");// aumenta el contraste
//run("Find Edges");

// Almacenando los datos de la imagen en un array
n = datos[3]/2; // mitad del tanaño de la imagen 595 pixeles
ValoresImg = newArray(n*n); // Total de pixeles de la imagen 595*595
ValoresImg_Filas = newArray(n);
max_c = newArray;
max_c_gauss = newArray;
max_c_una_franja = newArray;
prom_c_franjas = newArray;
dif = newArray();
prod = newArray(n);
max_c_centroide = newArray();
skewness_valo_1 = newArray();
kurtosis_valo_1 = newArray();



for (i=0;i<n;i++) {
	for (j=0;j<n;j++){
		ValoresImg[(n*i)+j]= getPixel(j,i);	// se almacena todos los valores de imagem n*n	
		ValoresImg_Filas[j]= getPixel(j,i);	// se almacenan los valores de la fila en curso (numero de fila i)
		};
	
		maxLocs_Filas= Array.findMaxima(ValoresImg_Filas, 0.01);//encuentra los valores maximos de la fila i
		maxLocs_Filas=Array.sort(maxLocs_Filas);//los ordeno de menor a mayor o izq a derecha		
		
	if (i==0) {
		Nume_Lineas_H = lengthOf(maxLocs_Filas); //Número de máximos en la primera fila, para determiar cuantos arreglos de maxi 
			                                     //tengo que crear	
	     };
	    // inicializacion en uno para la operacion despues 
		prod[i] = 1;  
		dif[i] = 1;
		
	     //Trabajado para una fila	     
	for (t = 0; t < Nume_Lineas_H; t++) {
		max_c[t+i*Nume_Lineas_H]=maxLocs_Filas[t]; //array con todos las pisiciones de los maximos
	      
	     //multiplicar cada maximo en cada fila para encontar error 
	     prod[i] *= maxLocs_Filas[t] ;	
	     	     
	     // vecindad
	     vecindad = Array.slice(ValoresImg_Filas,maxLocs_Filas[t]-15,maxLocs_Filas[t]+15);		     		     
	     Array.getStatistics(vecindad, min, max, mean, stdDev);
	     // almaceno los centros de las gausianas para cada franja
	     max_c_gauss[t+i*Nume_Lineas_H] = maxLocs_Filas[t]-15+Centro_Gaussiana(vecindad); 	
	     max_c_centroide [t+i*Nume_Lineas_H] = maxLocs_Filas[t]-15+Centro_centroide(vecindad);   
	     
	     // Diferencia entre el centro de la Gaussiana y el centro de intensidad
	     
	     //c = maxLocs_Filas[t] - 16 + Centro_Gaussiana(vecindad); //ajustando para adaptar a la X de la franja que correponde		     		
         if (t == 1) {	
         	Array.print(vecindad);	
         	print("\n");     
	         skewness_valo_1 [i]  = skewness(vecindad,mean,stdDev) ;
	         kurtosis_valo_1 [i] = kurtosis(vecindad,mean,stdDev);	
	     		     	     
	     }; 
         };	
	
		Overlay.show;	
		 
};	

//convirtiendo de pixeles a cm
//reduzco la matriz de 595 a 60 valores
//normalizar la matriz prod
Array.getStatistics(prod, min, max, mean, stdDev);
l = lengthOf(prod);
for (i = 0; i < l; i++) {
	prod[i] = prod[i]/ max;
};

prod_56=cover595to56(prod);

// buscando el centro y los limites reales de las franjas
max_c_c= newArray();
max_c_c = Array.sort(Array.copy(max_c)); //hay que hacerlo asi para evitar la referencia a los datos existentes
max_c_gauss=Array.sort(max_c_gauss); 



for (t = 0; t < Nume_Lineas_H; t++) {
		//se dibija los centros segun la intesidad no por el ajuste gausiano
	max_c_una_franja_int = Array.slice(max_c_gauss,t*595,(t+1)*595);
	dibuja_centros_y_gap(max_c_una_franja_int,prod_56);
	// se dibujan las franjas basados en ajuste
	max_c_una_franja = Array.slice(max_c_gauss,t*595,(t+1)*595); //en cada ciclo se obtienen las x de los max de intensidad
	Array.getStatistics(max_c_una_franja, min, max, mean, stdDev);
	prom_c_franjas = round(mean);
	Dibuja_Punto("green",1,prom_c_franjas-2,0,prom_c_franjas-2,595); // porque 1 mm equivale a ~3 pixeles (hay q usar 2) 
	Dibuja_Punto("green",1,prom_c_franjas+2,0,prom_c_franjas+2,595); // para una correcta visualizacion
	


	for (i = 0; i < 595; i++) {
		// almacendo la dif para una franja t
		dif[i+t*595]=Math.abs(max_c[t+i*(Nume_Lineas_H)] - mean); 
	};
		
	Overlay.show;		
}

//promedio la diferencia para cada fila es decir promedio a la vez tantos valores como franjas existan
prom_dif = newArray();
temp_dif = newArray(Nume_Lineas_H);

for (i = 0; i < 595; i++) {
	for (t = 0; t < Nume_Lineas_H; t++) {
		temp_dif[t] = dif[t*595+i];		
	};
	Array.getStatistics(temp_dif, min, max, mean, stdDev);
	prom_dif[i]=mean;
};

//convertir a mm la diferencia en pixeles
dif_56 = cover595to56(prom_dif);
dif_56_mm = newArray;

for (i = 0; i < lengthOf(dif_56); i++) {
	dif_56_mm[i]= dif_56[i]*0.336;
};


ploting();
print("return 0");
	





