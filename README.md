<html>

<head>
<meta http-equiv="Content-Language" content="es">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
</head>


<blockquote>
  <blockquote>
    <blockquote>

<table border="0" width="73%">
  <tr>
    <td width="109%"><font size="4"><b><i>Dise�o de un m�dulo para control de
      8 servos y 5 canales anal�gicos por bus I<sup>2</sup>C</i></b></font>
      <p>Por Alejandro Alonso Puig<br>
      Octubre 2.003<br>
     </td>
  </tr>
</table>
<hr>
<p align="justify"><br>
El presente repositorio incluye no solo los programas y esquemático del circuito en Eagle, 
sino también el informe técnico que describe el dise�o, tanto desde el punto de vista
electr�nico, como inform�tico de un placa para control por bus I<sup>2</sup>C
de 8 servos est�ndar de radiocontrol y 5 entradas anal�gicas (Conversi�n
anal�gica/digital). Las caracter�sticas principales del m�dulo presentado son
las siguientes:&nbsp;</p>
<ul>
  <li>
    <p align="justify">Act�a como Slave permitiendo seleccionar mediante
    switches dip la direcci�n que utilizar� en la red I<sup>2</sup>C.&nbsp;</li>
  <li>
    <p align="justify">Se puede establecer mediante bus I<sup>2</sup>C tanto la
    posici�n deseada de cada servo, como el sentido de giro y el Offset.&nbsp;</li>
  <li>
    <p align="justify">Se puede leer por bus I<sup>2</sup>C el valor digital (8
    bits) correspondiente a cualquiera de las 5 entradas anal�gicas de las que
    dispone.&nbsp;</li>
</ul>
<p align="justify">&nbsp;</p>
<p align="center"><img border="0" src="SVI2Ccon.jpg" width="503" height="378"></p>
<p align="justify">La ventaja que se obtiene con este tipo de m�dulos es
precisamente el control por bus I<sup>2</sup>C que permite tener varios m�dulos
de este tipo ventaja que se obtiene con este tipo de m�dulos es precisamente el
control por bus I<sup>2</sup>C que permite tener varios m�dulos de este tipo
conectados al mismo bus. De esta manera pueden controlarse gran cantidad de
servos desde un controlador principal sin apenas sobrecarga en el mismo.
Adicionalmente se tiene medida de valores anal�gicos, muy �til para
determinado tipo de sensores.</p>
<p><b>Nota</b>: Master y Slave han de estar conectados mediante tres hilos:
Masa, SCL y SDA. El m�dulo presentado incluye las resistencias de PullUp, por
lo que no es necesario a�adirlas.</p>
<p>