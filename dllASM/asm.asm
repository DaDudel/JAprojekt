;Maciej Duda gr 2 AEI sem 5
;JA projekt - filtr usredniajacy z histogramem

.data

.code
filtr proc EXPORT
	local ix: QWORD	;iterator x
	local iy: QWORD	;iterator y
	local x_max: QWORD	;maksymalna wartosc iteratora x
	local y_max: QWORD	;maksymalna wartosc iteratora y
	local imageWidth: QWORD	;szerokosc obrazka
	local imageHeight: QWORD	;wysokosc obrazka
	local imageFin: QWORD	;obraz po filtracji
	local image: QWORD	;obraz przed filtracja
	local Rvalue: SDWORD	;zmienna na kolor czerwony
    local Gvalue: SDWORD	;zmienna na kolor zielony
    local Bvalue: SDWORD	;zmienna na kolor niebieski

	push RBP        ;zapis adresow rejestru RBP, aby po wykonaniu procedury zachowac spojnosc w pamieci
    push RDI        ;zapis adresow rejestru RDI, aby po wykonaniu procedury zachowac spojnosc w pamieci       
    push RSP		;zapis adresow rejestru RSP, aby po wykonaniu procedury zachowac spojnosc w pamieci
	push RSI		;zapis adresow rejestru RSI, aby po wykonaniu procedury zachowac spojnosc w pamieci

	;zerowanie zmiennych
	xor rax, rax	;zerowanie rax
	mov Rvalue, eax	;zerowanie Rvalue
	mov Gvalue, eax	;zerowanie Gvalue
	mov Bvalue, eax	;zerowanie Bvalue
	mov ix, rax	;zerowanie iteratora x
	mov iy, rax	;zerowanie iteratora y
	
	mov rax, rcx	;wczytanie rcx do rax
	mov image, rax	;zapis wskaznikow na tablice w rejestrach

	mov rax, rdx	;wczytanie rdx do rax
	mov rbx, 3		;wczytanie 3 do rbx
	mul rbx			;mno¿enie razy 3 (kazdy piksel posiada wartosci R, G, B)
	mov imageWidth, rax	;zapis szerokosci obrazu w zmiennej
	mov rax, r8		;wczytanie r8 do rax
	mov imageHeight, rax	;zapis wysokosci obrazu w zmiennej

	mov imageFin, r9	;zapis wskaŸnika na tablice

	mov rax, imageWidth	;wczytanie szerokoœci obrazu do rax
	sub rax, 6			;cofniêcie siê o 2 piksele
	mov x_max, rax	;ustawianie max iteratora
	mov rax, imageHeight	;wczytanie wysokoœci obrazu do rax
	sub rax, 2			;cofniêcie o 2 pixele
	mov y_max, rax	;ustawianie max iteratora

PETLAY:	;iteracja po tablicy (wiersze obrazu)
	mov ecx, 0	;zerowanie ecx
	mov edi, 0	;zerowanie edi
	inc iy	;inkrementacja iy
	mov ix, 0		;zerowanie ix

PETLAX:	;iteracja po tablicy (kolumny obrazu)
	add ix, 3	;zwiekszenie iteratora o 3 (kolejny piksel)

	xor rax, rax	;zerowanie rax

	mov Rvalue, eax	;zerowanie Rvalue
	mov Gvalue, eax	;zerowanie Gvalue
	mov Bvalue, eax	;zerowanie Bvalue

	;sumowanie wartosci RGB dla 9 pikseli (1 filtrowany i 8 otaczajacych go)
	;GORA LEWO
	;SUMA RED
	mov rax, iy		;wczytanie iy do rax
	dec rax					;zmniejszenie o 1
	mul imageWidth		;pomnozenie przez szerokosc obrazu (obraz przechowywany jest w tablicy jednowymiarowej)
	add rax, ix		;dodanie ix do rax
	sub rax, 3				;przesuniecie o 1 piksel w lewo
	add rax, 0				;dotarcie do wartoœci RED (w tym przypadku nie trzeba nic robic)
	add rax, image			;przejœcie do odpowiedniego miejsca w pamiêci
	xor rbx, rbx			;zerowanie rbx
	mov bl, [rax]			;odczytanie wartoœci RED
	xor rax, rax			;zerowanie rax
	mov al, bl				;wczytanie bl do al
	add Rvalue, eax			;dodanie eax do Rvalue

	;SUMA GREEN
	mov rax, iy		;wczytanie iy do rax
	dec rax					;zmniejszenie o 1
	mul imageWidth		;pomno¿enie przez szerokosc obrazu
	add rax, ix		;dodanie ix
	sub rax, 3				;przesuniecie o 1 piksel w lewo
	add rax, 1				;dotarcie do wartoœci GREEN (przesuniecie o jedno pole w tabeli)
	add rax, image			;przejœcie do odpowiedniego miejsca w pamiêci
	xor rbx, rbx			;zerowanie rbx
	mov bl, [rax]			;odczytanie wartoœci GREEN
	xor rax, rax			;zerowanie rax
	mov al, bl				;wczytanie bl do al
	add Gvalue, eax			;dodanie eax do sumy wartoœci GREEN

	;SUMA BLUE
	mov rax, iy		;wczytanie iy do rax
	dec rax					;zmniejszenie o 1
	mul imageWidth		;pomno¿enie przez szerokosc obrazu
	add rax, ix		;dodanie ix
	sub rax, 3				;przesuniecie o 1 piksel w lewo
	add rax, 2				;dotarcie do wartoœci BLUE
	add rax, image			;przejœcie do odpowiedniego miejsca w pamiêci
	xor rbx, rbx			;zerowanie rbx
	mov bl, [rax]			;odczytanie wartoœci BLUE
	xor rax, rax			;zerowanie rax
	mov al, bl				;wczytanie bl do al
	add Bvalue, eax			;dodanie eax do sumy wartoœci GREEN

	;w analogiczny sposob zostaja zsumowane wartosci z pozostalych 8 pikseli
	;GORA SRODEK
	;SUMA RED
	mov rax, iy		
	dec rax
	mul imageWidth
	add rax, ix
	add rax, 0				
	add rax, 0				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]				
	xor rax, rax
	mov al, bl
	add Rvalue, eax

	;SUMA GREEN
	mov rax, iy		
	dec rax
	mul imageWidth
	add rax, ix
	add rax, 0				
	add rax, 1				
	add rax, image
	xor rbx, rbx
	mov rbx, [rax]
	xor rax, rax
	mov al, bl
	add Gvalue, eax

	;SUMA BLUE
	mov rax, iy		
	dec rax
	mul imageWidth
	add rax, ix
	add rax, 0				
	add rax, 2				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Bvalue, eax


	;GORA PRAWO
	;RED
	mov rax, iy		
	dec rax
	mul imageWidth
	add rax, ix
	add rax, 3				
	add rax, 0				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]				
	xor rax, rax
	mov al, bl
	add Rvalue, eax

	;GREEN
	mov rax, iy		
	dec rax
	mul imageWidth
	add rax, ix
	add rax, 3				
	add rax, 1				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Gvalue, eax

	;BLUE
	mov rax, iy		
	dec rax
	mul imageWidth
	add rax, ix
	add rax, 3				
	add rax, 2				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Bvalue, eax


	;SRODEK LEWO
	;RED
	mov rax, iy		
	mul imageWidth
	add rax, ix
	sub rax, 3				
	add rax, 0				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]			
	xor rax, rax
	mov al, bl			
	add Rvalue, eax

	;GREEN
	mov rax, iy	
	mul imageWidth
	add rax, ix
	sub rax, 3				
	add rax, 1				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Gvalue, eax

	;BLUE
	mov rax, iy	
	mul imageWidth
	add rax, ix
	sub rax, 3				
	add rax, 2				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Bvalue, eax


	;SRODEK SRODEK
	;RED
	mov rax, iy		
	mul imageWidth
	add rax, ix
	sub rax, 0				
	add rax, 0				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl				
	add Rvalue, eax

	;GREEN
	mov rax, iy	
	mul imageWidth
	add rax, ix
	sub rax, 0				
	add rax, 1				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Gvalue, eax

	;BLUE
	mov rax, iy	
	mul imageWidth
	add rax, ix
	sub rax, 0				
	add rax, 2				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Bvalue, eax


	;SRODEK PRAWO
	;RED
	mov rax, iy		
	mul imageWidth
	add rax, ix
	add rax, 3				
	add rax, 0				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl				
	add Rvalue, eax

	;GREEN
	mov rax, iy	
	mul imageWidth
	add rax, ix
	add rax, 3				
	add rax, 1				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Gvalue, eax

	;BLUE
	mov rax, iy		
	mul imageWidth
	add rax, ix
	add rax, 3				
	add rax, 2				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl 
	add Bvalue, eax


	;DOL LEWO
	;RED
	mov rax, iy	
	inc rax				
	mul imageWidth
	add rax, ix
	sub rax, 3				
	add rax, 0				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]			
	xor rax, rax
	mov al, bl																	
	add Rvalue, eax																			
																							
	;GREEN
	mov rax, iy	
	inc rax				
	mul imageWidth
	add rax, ix
	sub rax, 3				
	add rax, 1				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Gvalue, eax

	;BLUE
	mov rax, iy		
	inc rax				
	mul imageWidth
	add rax, ix
	sub rax, 3				
	add rax, 2				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Bvalue, eax


	;DOL SRODEK
	;RED
	mov rax, iy	
	inc rax				
	mul imageWidth
	add rax, ix
	sub rax, 0			
	add rax, 0			
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Rvalue, eax

	;GREEN
	mov rax, iy	
	inc rax				
	mul imageWidth
	add rax, ix
	sub rax, 0			
	add rax, 1			
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Gvalue, eax

	;BLUE
	mov rax, iy		
	inc rax				
	mul imageWidth
	add rax, ix
	sub rax, 0				
	add rax, 2				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Bvalue, eax


	;DOL PRAWO
	;RED
	mov rax, iy	
	inc rax				
	mul imageWidth
	add rax, ix
	add rax, 3				
	add rax, 0				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Rvalue, eax

	;GREEN
	mov rax, iy	
	inc rax				
	mul imageWidth
	add rax, ix
	add rax, 3				
	add rax, 1				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Gvalue, eax

	;BLUE
	mov rax, iy	
	inc rax				
	mul imageWidth
	add rax, ix
	add rax, 3				
	add rax, 2				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	add Bvalue, eax


	;po zsumowaniu wartosci nalezy podzielic je przez 9

	;DZIELENIE RED
	
	xor rax, rax	;zerowanie rax
	xor rbx, rbx	;zerowanie rbx
	xor eax, eax	;zerowanie eax
	xor rcx, rcx	;zerowanie rcx

	mov eax,Rvalue	;wczytanie Rvalue do eax
	xorps xmm0, xmm0	;zerowanie xmm0
    cvtsi2ss xmm0, eax	;wczytanie eax do xmm0
    mov rdx, 9	;zapisanie 9 w rdx
    cvtsi2ss xmm1, rdx	;wczytanie rdx do xmm1
    divss xmm0, xmm1	;dzielenie przez 9
	cvtss2si eax, xmm0	;wczytanie wyniku do eax
	mov Rvalue,eax	;wczytanie wyniku dzielenia do Rvalue
    
	;DZIELENIE GREEN

	xor rax, rax	;zerowanie rax
	xor rbx, rbx	;zerowanie rbx
	xor eax, eax	;zerowanie eax
	xor rcx, rcx	;zerowanie rcx

	mov eax,Gvalue	;wczytanie Gvalue do eax
	xorps xmm0, xmm0	;zerowanie xmm0
    cvtsi2ss xmm0, eax	;wczytanie eax do xmm0
    mov rdx, 9	;zapisanie 9 w rdx
    cvtsi2ss xmm1, rdx	;wczytanie rdx do xmm1
    divss xmm0, xmm1	;dzielenie przez 9
	cvtss2si eax, xmm0	;wczytanie wyniku do eax
	mov Gvalue,eax	;wczytanie wyniku dzielenia do Gvalue

	;DZIELENIE BLUE

	xor rax, rax	;zerowanie rax
	xor rbx, rbx	;zerowanie rbx
	xor eax, eax	;zerowanie eax
	xor rcx, rcx	;zerowanie rcx

	mov eax,Bvalue	;wczytanie Bvalue do eax
	xorps xmm0, xmm0	;zerowanie xmm0
    cvtsi2ss xmm0, eax	;wczytanie eax do xmm0
    mov rdx, 9	;zapisanie 9 w rdx
    cvtsi2ss xmm1, rdx	;wczytanie rdx do xmm1
    divss xmm0, xmm1	;dzielenie przez 9
	cvtss2si eax, xmm0	;wczytanie wyniku do eax
	mov Bvalue,eax	;wczytanie wyniku dzielenia do Bvalue

	;ZAPIS DO TABLICY

	mov rcx, 3	;wczytanie 3 do rcx

	;ZAPIS WARTOSCI RED

	xor rax, rax	;zerowanie rax
	mov rax, iy		;wczytanie iy do rax
	mul imageWidth	;mnozenie razy szerokosc obrazka
	add rax, ix	;dodanie ix
	add rax, 0			;zostanie na wartosci RED
	add rax, imageFin	;przejœcie do odpowiedniego miejsca w pamiêci
	xor rbx, rbx	;zerowanie rbx
	mov ebx, Rvalue	;wczytanie Rvalue do ebx
	mov [rax], bl	;zapis

	;ZAPIS WARTOSCI GREEN

	xor rax, rax	;zerowanie rax
	mov rax, iy	;wczytanie iy do rax
	mul imageWidth	;mno¿enie razy szerokosc obrazka
	add rax, ix	;dodanie ix
	add rax, 1			;skok do wartosci GREEN
	add rax, imageFin	;przejœcie do odpowiedniego miejsca w pamiêci
	xor rbx, rbx	;zerowanier rbx
	mov ebx, Gvalue	;wczytanie Gvalue do ebx
	mov [rax], bl	;zapis

	;ZAPIS WARTOSCI BLUE

	xor rax, rax	;zerowanie rax
	mov rax, iy	;wczytanie iy do rax
	mul imageWidth	;mnozenie razy szerokosc obrazu
	add rax, ix	;dodanie ix
	add rax, 2			;skok do wartosci BLUE
	add rax, imageFin	;przejœcie do odpowiedniego miejsca w pamiêci
	xor rbx, rbx	;zerowanie rbx
	mov ebx, Bvalue	;wczytanie Bvalue do ebx
	mov [rax], bl	;zapis

	;przejscie do nastepnego piksela

	mov rax, ix	;wczytanie ix do rax
	cmp rax, x_max	;porownanie czy zostal osiagniety max
	JB PETLAX	;jesli nie to skok do PETLAX

	mov rax, iy	;wczytanie iy do rax
	cmp rax, y_max	;porownanie czy zostal osiagniety max
	JB PETLAY	;jesli nie to skok do PETLAY

	;zerowanie rejestrow i przywracanie wartosci
	xor rax, rax	;zerowanie rax
	xor rbx, rbx	;zerowanie rbx
	xor rcx, rcx	;zerowanie rcx
	xor rdx, rdx	;zerowanie rdx
	xor r8, r8		;zerowanie r8
	xor r9, r9		;zerowanie r9
	mov image, rax	;zerowanie image
	mov imageFin, rax	;zerowanie imageFin

	pop rsi			;przywrocenie wartosci rejestru rsp
	pop rsp         ;przywrocenie wartosci rejestru rsp
    pop rdi         ;przywrocenie wartosci rejestru rdi
    pop rbp		    ;przywrocenie wartosci rejestru rbp
	
	xor rax, rax	;wyzerowanie rax
	ret	;koniec procedury

filtr endp

end