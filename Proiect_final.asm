.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

includelib msvcrt.lib
extern exit: proc
extern scanf: proc
extern printf: proc
extern malloc: proc
extern free: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.data

;NODE struct 
;	val DD 0
;	next DD 0
;NODE ends

;vectorii first si last
first DD 10 dup(0);Tabela -> contine first-ul fiecarei liste
last DD 10 dup(0);Last vector -> contine last-ul fiecarei liste

;mesaje
mesaj_meniu DB 13,10,13,10,"INTRODUCETI OPERATIUNEA DORITA:",13,10,"1 - adaugare nod",13,10,"2 - cautare valoare",13,10,"3 - afisare continut",13,10,"4 - stergere nod",13,10,"5 - iesire",13,10,0
mesaj_eroare DB 13,10,13,10,"OPERATIUNEA INTRODUSA ESTE INVALIDA !!!",13,10,"MAI INCERCATI",0
linii DB 13,10,"-----------------------------------------------------------",0
afisare0 DB 13,10,"CONTINUTUL TABELEI ESTE:",13,10,0
afisarex DB 13,10,"Tab(%d): ",0
formatcitire DB "%d",0
formatafisare DB "%d ",0
form_intr DB 13,10,"Introduceti o valoare: ",0
mesaj_adaugat DB 13,10,"Valoarea a fost adaugata!",0
mesaj_e_deja DB 13,10,"Valoarea era deja in tabela!",0
mesaj_valoare_cautata DB 13,10,13,10,"INTRODUCETI VALOAREA CAUTATA: ",0
mesaj_nu_este DB 13,10,"Valoarea %d nu se afla in lista !",0
mesaj_este DB 13,10,"Valoarea %d a fost gasita pe pozitia %d !",0
mesaj_valoare_de_sters DB 13,10,"Introduceti valoarea de sters din tabela: ",0
mesaj_sters DB 13,10,"Valoarea %d a fost stearsa din tabela",0

var DD 0
adauga DD 0
index DD 0
p DD 0
q DD 0

.code


;____________________________________________________________________________________________________________________________________________
adauga_nod proc
	push ebx;salvam pe stiva valoarea veche din ebx
	mov ebx,esp;salvam in ebx varful actual al stivei
	
	push offset form_intr;afisam mesajul "Introduceti o valoare: "
	call printf
	add esp,4
	
	push offset adauga;citim de la tastatura valoarea noua
	push offset formatcitire
	call scanf
	add esp,8
	
	push adauga;verificam daca valoarea se afla deja in tabela
	call cautare
	cmp eax,1
	je e_deja
	
	push 8;alocam memorie pentru un nod nou
	call malloc
	add esp,4
	mov var,eax;in var vom avea intotdeauna adresa noului nod
	
	mov edx,adauga;ebx <- adauga(valoarea noua)
	mov edi,var;edi <- adresa nodului
	mov dword ptr[edi],edx;var.val=adauga
	mov dword ptr[edi+4],0;var.next=NULL
	
	push edx
	call hash_function;edx <- valoarea_adaugata%10 sau pozitia din tabela la care se va adauga noua valoare
	
	cmp dword ptr[first[edx*4]],0;daca first nu este 0, adica daca lista nu este nula, sari la legatura; altfel, continua
	jne legatura
	
	mov eax,var
	mov dword ptr[first[edx*4]],eax;first=var
	jmp last_move
	
legatura:
	mov edi,dword ptr[last[edx*4]];ebx <- last
	mov eax,var;eax <- var(adresa nodului de adaugat)
	mov dword ptr[edi+4],eax;last.next <- var
	
	
last_move:
	mov edi,var
	mov dword ptr[last[edx*4]],edi;last=var
	
	push offset mesaj_adaugat
	call printf
	add esp,4
	jmp done
e_deja:
	mov edi,adauga;afisam mesajul "Valoarea era deja in tabela!"
	push offset mesaj_e_deja
	call printf
	add esp,8
done:	
	mov esp,ebx;restabilim stiva
	pop ebx;restabilim valoarea lui ebx initiala
	ret;reluam fluxul executiei de dinainte de apel
adauga_nod endp


;____________________________________________________________________________________________________________________________________________	
hash_function proc
	push ebx;salvam pe stiva valoarea veche din ebx
	mov ebx,esp;salvam in ebx varful actual al stivei
	
	mov eax,dword ptr[ebx+8];mutam in eax parametrul functiei
	mov edx,0;edx <- 0
	mov edi,10;edi <- 10
	div edi;eax <- edx:eax / 10; edx <- edx:eax % 10
	
	mov esp,ebx;restabilim stiva
	pop ebx;restabilim valoarea lui ebx initiala
	ret 4;stergem parametri de pe stiva si reluam fluxul executiei de dinainte de apel
hash_function endp


;____________________________________________________________________________________________________________________________________________
afisare proc
	push ebx;salvam pe stiva valoarea veche din ebx
	mov ebx,esp;salvam in ebx varful actual al stivei
	
	push offset linii;afisam un rand cu linii
	call printf
	add esp,4
	
	push offset afisare0;afisam mesajul "CONTINUTUL TABELE ESTE:"
	call printf
	add esp,4
	
	mov ebp,0;initializam ebp cu 0, ebp este folosit ca index al tabelei
next:
	push ebp;afisam "Tab(ebp): "
	push offset afisarex
	call printf
	add esp,8
	
	mov edi,dword ptr[first[ebp*4]]
	cmp edi,0
	je stop
redo:
	cmp dword ptr[edi+4],0;verifica daca suntem la ulimul nod
	je ultim;daca da sare la ultim
	push dword ptr[edi];afisare nod
	push offset formatafisare
	call printf
	add esp,8
	mov edx,edi
	mov edi,dword ptr[edx+4];edi <- edi.next
	jmp redo
	
ultim:
	push dword ptr[edi];afiseaza ultimul nod
	push offset formatafisare
	call printf
	add esp,8
	
stop:
	inc ebp;se incrementeaza indexul de parcurgere al tabelei
	cmp ebp,10
	jl next;daca indexul e mai mic decat 10 mai afisam listele ramase, altfel terminam
	
	push offset linii;se afiseaza un rand cu linii
	call printf
	add esp,4
	
	mov esp,ebx;restabilim stiva
	pop ebx;restabilim valoarea lui ebx initiala
	ret;reluam fluxul executiei de dinainte de apel
afisare endp


;____________________________________________________________________________________________________________________________________________
cautare proc
	push ebx;salvam pe stiva valoarea veche din ebx
	mov ebx,esp;salvam in ebx varful actual al stivei
	
	mov edi,dword ptr[ebx+8];edi <- valoarea cautata
	mov var,edi
	push edi
	call hash_function;edx <- pozitia din tabela la care se va face cautarea
	
	mov ecx,dword ptr[first[edx*4]];ecx <- first[edx]
	
cauta:
	cmp ecx,0;daca adresa de cautare este la NULL inseamna ca lista e goala\
			 ;sau am ajuns la capat fara sa gasim valoarea, deci aceasta nu exista
	je nu_este
	mov edi,var
	cmp dword ptr[ecx],edi;daca valoarea nodului curent este egala cu valoarea cautata inseamna ca am gasit-o
	je este
	
	mov ecx,dword ptr[ecx+4];ecx <- ecx.next
	jmp cauta;cautam in urmatorul nod
	
nu_este:
	mov eax,0
	jmp done
este:
	mov eax,1
done:	
	mov esp,ebx;restabilim stiva
	pop ebx;restabilim valoarea lui ebx initiala
	ret 4;stergem argumentele de pe stiva si reluam fluxul executiei de dinainte de apel
cautare endp


;_________________________________________________________________________________________________________________________________________
stergere proc
	push ebx;salvam pe stiva valoarea veche din ebx
	mov ebx,esp;salvam in ebx varful actual al stivei
	
	push offset mesaj_valoare_de_sters;afisam un mesaj
	call printf
	add esp,4
	
	push offset var;citim valoarea de sters
	push offset formatcitire
	call scanf
	add esp,8
	
	push var;apelam hash_function pentru a afla pozitia din tabela unde vom cauta valoarea de sters
	call hash_function
	mov index,edx
	
	push var;verificam daca valoarea se afla in tabela
	call cautare
	
	cmp eax,1
	jne nu_este;daca nu este sarim la nu_este
	
	mov edx,index;edx <- hash_function(var)
	mov ecx,dword ptr[first[edx*4]];ecx <- first(edx)
	mov edi,dword ptr[last[edx*4]];edi <- last(edx)
	cmp ecx,edi;comparam first cu last
	je sterge_singurul_nod;daca sunt egale inseamna ca exista un singur nod la first(edx), nodul care va trebui sters; sare la stege_singurul_nod:
	
	mov eax,dword ptr[ecx];eax <- nod_curent.val
	cmp eax,var;verificam daca am gasit valoarea cautata
	je sterge_first;daca da, sare la sterge_first
	
	mov edx,index;edx <- hash_function(var)
	mov ecx,dword ptr[first[edx*4]];ecx <- first(edx)
	mov edi,dword ptr[ecx+4];edi <- nod_curent.next
cat_timp:
	;while(nod_curent.val != val && nod_curent.next != last); unde ecx <- nod_anterior si edi <- nod_curent
	;	nod_curent <- nod_curent.next
	mov eax,dword ptr[edi];eax <- nod_curent.val
	cmp eax,var;verificam daca am gasit valoarea cautata
	je sterge_nod;daca da, sare la sterge_nod
			
	mov esi,dword ptr[edi+4];esi <- nod_curent.next
	mov edx,index;edx <- hash_function(var)
	mov eax,dword ptr[last[edx*4]];eax <- last(edx)
	cmp esi,eax;verificam daca nodul urmator este ultimul(last)
	je sterge_last;daca da,inseamna ca nodul cautat este last; sare la sterge_last
	
	mov ecx,dword ptr[ecx+4];nod_curent <- nod_curent.next
	mov edi,dword ptr[edi+4];nod_curent <- nod_curent.next
	
	jmp cat_timp
	
sterge_nod:
	mov esi,dword ptr[edi+4];esi <- nod_curent.next
	mov dword ptr[ecx+4],esi;nod_anterior.next <- nod_curent.next
	push edi
	call free
	jmp sters
	
sterge_last:
	mov edx,index
	mov dword ptr[last[edx*4]],edi;last <- nod_curent
	mov dword ptr[edi+4],0;nod_curent.next <- null
	mov esi,dword ptr[edi+4];esi <- nod_curent.next(last)
	push esi
	call free;free(last)
	jmp sters
	
sterge_first:
	mov eax,dword ptr[ecx+4]
	mov dword ptr[first[edx*4]],eax
	push ecx
	call free
	jmp sters
	
sterge_singurul_nod:
	mov dword ptr[first[edx*4]],0;stergem singurul nod din lista first(hash_function(var))
	mov dword ptr[last[edx*4]],0
	push ecx
	call free
sters:
	push var
	push offset mesaj_sters
	call printf
	add esp,8
	
	jmp done
	
nu_este:
	push var
	push offset mesaj_nu_este;afisam un mesaj corespunzator si incheiem
	call printf
	add esp,4
	
done:
	mov esp,ebx;restabilim stiva
	pop ebx;restabilim valoarea lui ebx initiala
	ret;reluam fluxul executiei de dinainte de apel
	
stergere endp
;____________________________________________________________________________________________________________________________________________
menu proc
	push ebx;salvam pe stiva valoarea veche din ebx
	mov ebx,esp;salvam in ebx varful actual al stivei
	
Meniu:
	push offset mesaj_meniu;afisam mesajul meniului
	call printf
	add esp,4
	
	push offset var;citim optiunea
	push offset formatcitire
	call scanf
	add esp,8
	
	cmp var,1;compara pentru adaugare nod
	je adaugare
	cmp var,2;compara pentru cautare
	je cauta
	cmp var,3;compara pentru afisare
	je afiseaza
	cmp var,4;compara pentru stergere nod
	je sterge
	cmp var,5;compara pentru iesire
	je iesire
	jmp optiune_invalida;daca optiunea e invalida va face acest salt
	
adaugare:
	call adauga_nod
	jmp Meniu
cauta:
	push offset mesaj_valoare_cautata;afisam mesajul "Introduceti valoarea cautata: "
	call printf
	add esp,4
	
	push offset var;folosim variabila var pentru a memora valoarea cautata
	push offset formatcitire
	call scanf
	add esp,8
	
	push var;apelam funtia cautare cu parametrul var
	call cautare
	cmp eax,1;verificam daca valoarea cautata exista in tabela sau nu
	je da
	mov edi,var
	push edi;afisam un mesaj corespunzator
	push offset mesaj_nu_este
	call printf
	add esp,8
	jmp Meniu
	da:
	mov edi,var
	push edx;afisam un mesaj corespunzator
	push edi
	push offset mesaj_este
	call printf
	add esp,12
	jmp Meniu

afiseaza:
	call afisare
	jmp Meniu

sterge:
	call stergere
	jmp Meniu
	
optiune_invalida:
	push offset mesaj_eroare
	call printf
	add esp,4
	jmp Meniu

iesire:
	mov esp,ebx;restabilim stiva
	pop ebx;restabilim valoarea lui ebx initiala
	ret;reluam fluxul executiei de dinainte de apel
menu endp
	
;____________________________________________________________________________________________________________________________________________
;____________________________________________________________________________________________________________________________________________
;____________________________________________________________________________________________________________________________________________
;____________________________________________________________________________________________________________________________________________
;____________________________________________________________________________________________________________________________________________
start:
	
	call menu;apelam functia menu

	push 0
	call exit
end start