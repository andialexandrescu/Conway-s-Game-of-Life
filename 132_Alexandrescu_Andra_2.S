.data
    m: .space 4 ;# nr linii
    n: .space 4 ;# nr coloane
    p: .space 4 ;# nr celule vii
    pIndex: .space 4
    k: .space 4 ;# k nr evolutii
    kIndex: .space 4
    i: .space 4
    j: .space 4
    matrix: .space 1600
    s: .space 4 ;# folosit pentru suma vecinilor
    matrixs: .space 1600
    lineIndex: .space 4
    columnIndex: .space 4
    
    inputFileDescriptor: .space 4
    outputFileDescriptor: .space 4

    readAccessMode: .asciz "r"
    writeAccessMode: .asciz "w"
    inputFileName: .asciz "in.txt"
    outputFileName: .asciz "out.txt"
    formatFPrintf: .asciz "%ld "
    formatFScanf: .asciz "%ld"
    newLine: .asciz "\n"
    formatNewline: .asciz "%s"
.text
.global main
main:
;# ALGORITM
;# FILE* inputFileDescriptor = fopen("in.txt", "r")
;# FILE* outputFileDescriptor = fopen("out.txt", "w")

;# fscanf(inputFileDescriptor, "%ld", &variabila_input)

;# fprintf(outputFileDescriptor, "%ld ", variabila_output); fprintf(outputFileDescriptor, "%s", &variabila_output)

;# fclose(inputFileDescriptor)
;# fclose(outputFileDescriptor)

    ;# fisierul de intrare e citit folosind modul de accesare read, din moment ce toate datele necesare vor fi preluate de acolo
    ;# eax = fopen(nume_fisier, mod_accesare)
    pushl $readAccessMode
    pushl $inputFileName
    call fopen
    addl $8, %esp

    movl %eax, inputFileDescriptor ;# salvare valoare returnata fopen in file descriptor-ul fisierului curent
    
    ;# se procedeaza similar pentru fisierul de iesire
    pushl $writeAccessMode
    pushl $outputFileName
    call fopen
    addl $8, %esp

    movl %eax, outputFileDescriptor
    
    ;# citire m linii din fisierul de input
    ;# fscanf(descriptor_fisier, &formatFScanf, &var_1, ...)
    pushl $m
    pushl $formatFScanf
    pushl inputFileDescriptor
    call fscanf
    addl $12, %esp
    
    ;# citire n coloane
    pushl $n
    pushl $formatFScanf
    pushl inputFileDescriptor
    call fscanf
    addl $12, %esp
    
    ;# citire p - nr celule vii
    pushl $p
    pushl $formatFScanf
    pushl inputFileDescriptor
    call fscanf
    addl $12, %esp
    
    movl $0, pIndex
    addl $2, m
    addl $2, n
for_perechi: ;# for(pIndex=0; pIndex<p; pIndex++)
    movl pIndex, %ecx
    cmp %ecx, p
    je citire_k

    ;# citire pozitiile din matrice la care se afla celulele vii
    pushl $i
    pushl $formatFScanf
    pushl inputFileDescriptor
    call fscanf
    add $12, %esp

    pushl $j
    pushl $formatFScanf
    pushl inputFileDescriptor
    call fscanf
    add $12, %esp

    ;# for(i=0; i<m_init+2; i++){ for(j=0; j<n_init+2; j++) ... }
    ;# matrix[i+1][j+1] = 1 (celula vie); eax = (i+1) * (n_init+2) + (j+1); GRAF ORIENTAT
    movl i, %eax
    addl $1, %eax
    movl $0, %edx ;# pt a nu afecta inmultirea
    mull n
    addl j, %eax
    addl $1, %eax
    lea matrix, %edi
    movl $1, (%edi, %eax, 4)

    incl pIndex
    jmp for_perechi
citire_k:
    ;# citire k - nr evolutii
    pushl $k
    pushl $formatFScanf
    pushl inputFileDescriptor
    call fscanf
    add $12, %esp
    
    ;# doar in eticheta for_perechi, care parcurge matricea extinsa si atribuie val de 1 perechilor de noduri (i, j), este nevoie de m_init+2 si n_init+2, deci se revine la valorile initiale introduse [ocazional vor trebui sa se realizeze operatiile addl $2, n si subl $2, n, din moment ce matricele matrix si matrixs au elemente care se apeleaza dupa formula (lineIndex+1)*(n_init+2)+(columnIndex)]
    subl $2, m 
    subl $2, n
movl $0, kIndex
afis_k_evolutie: ;# for(kIndex=0; kIndex<k; kIndex++)
    movl kIndex, %ecx
    cmp %ecx, k
    je afis_analiza_evolutie
    
    ;# prelucrari
    ;# MOD DE APELARE (chain de etichete): compunere matrice s -> analiza evolutie -> etichete intermediare -> afisare analiza evolutie
    jmp compunere_matrice_s
    
cont_afis_k_evolutie:
    incl kIndex
    jmp afis_k_evolutie

compunere_matrice_s: 
    movl $0, lineIndex
    for1_linii: ;# for(lineIndex=0; lineIndex<m_init; lineIndex++)
        movl lineIndex, %ecx
        cmp %ecx, m
        je analiza_evolutie

        movl $0, columnIndex
        for1_coloane: ;# for(columnIndex=0; columnIndex<n_init; columnIndex++)
            movl columnIndex, %ecx
            cmp %ecx, n
            je cont_for1_linii
            
	    movl s, %ebx
	    addl $2, n

            ;# a[i-1][j-1] => (lineIndex) * (n_init+2) + (columnIndex)
            movl lineIndex, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# a[i-1][j] => (lineIndex) * (n_init+2) + (columnIndex+1)
            movl lineIndex, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax
            addl $1, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# a[i-1][j+1] => (lineIndex) * (n_init+2) + (columnIndex+2)
            movl lineIndex, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax
            addl $2, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# a[i][j-1] => (lineIndex+1) * (n_init+2) + (columnIndex)
            movl lineIndex, %eax
            addl $1, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# a[i][j+1] => (lineIndex+1) * (n_init+2) + (columnIndex+2)
            movl lineIndex, %eax
            addl $1, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax
            addl $2, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# a[i+1][j-1] => (lineIndex+2) * (n_init+2) + (columnIndex)
            movl lineIndex, %eax
            addl $2, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# a[i+1][j] => (lineIndex+2) * (n_init+2) + (columnIndex+1)
            movl lineIndex, %eax
            addl $2, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax
            addl $1, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# a[i+1][j+1] => (lineIndex+2) * (n_init+2) + (columnIndex+2)
            movl lineIndex, %eax
            addl $2, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax
            addl $2, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# el curent din matrixs => (lineIndex+1) * (n_init+2) + (columnIndex+1)
            movl lineIndex, %eax
            addl $1, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax
            addl $1, %eax
            
            lea matrixs, %edi
            movl %ebx, (%edi, %eax, 4)
            
            incl columnIndex
            subl $2, n
            jmp for1_coloane

    cont_for1_linii:
        incl lineIndex
        jmp for1_linii

analiza_evolutie:
    movl $0, lineIndex
    for2_linii: ;# for(lineIndex=0; lineIndex<m_init; lineIndex++)
        movl lineIndex, %ecx
        cmp %ecx, m
        je cont_afis_k_evolutie

        movl $0, columnIndex
        for2_coloane: ;# for(columnIndex=0; columnIndex<n_init; columnIndex++)
            movl columnIndex, %ecx
            cmp %ecx, n
            je cont_for2_linii
            
            ;# eax = (lineIndex+1) * (n_init+2) + (columnIndex+1)
            movl lineIndex, %eax
            addl $1, %eax
            movl $0, %edx
            addl $2, n
            mull n
            subl $2, n
            addl columnIndex, %eax
            addl $1, %eax
   
            lea matrix, %edi
            movl (%edi, %eax, 4), %ebx
            
            ;# if(matrix[lineIndex+1][columnIndex+1]==1): jmp celula_vie else: jmp celula_moarta
            cmp $1, %ebx
            je celula_vie
            cmp $0, %ebx
            je celula_moarta
            
cont_analiza_evolutie:
            incl columnIndex
            jmp for2_coloane

    cont_for2_linii:
        incl lineIndex
        jmp for2_linii
        
celula_vie:
    ;# in ebx e elementul curent, adica celula vie, iar in eax e pozitia curenta a celulei
    lea matrixs, %esi
    movl (%esi, %eax, 4), %ebx ;# compar elementul corespunzator din matrixs (pt ca suma e corespondenta elementului curent verificat)
    
    cmp $2, %ebx
    jb elem_modif_in_0
    
    cmp $3, %ebx
    jg elem_modif_in_0
    
    cont_celula_vie:
        jmp cont_analiza_evolutie
    
celula_moarta:
    ;# in ebx e elementul curent, adica celula moarta, iar in eax e pozitia curenta a celulei
    lea matrixs, %esi
    movl (%esi, %eax, 4), %ebx
    
    cmp $3, %ebx
    je elem_modif_in_1
    
    cont_celula_moarta:
        jmp cont_analiza_evolutie
        
elem_modif_in_0:
    lea matrix, %edi
    movl $0, (%edi, %eax, 4)
    
    jmp cont_celula_vie
    
elem_modif_in_1:
    lea matrix, %edi
    movl $1, (%edi, %eax, 4)
    
    jmp cont_celula_moarta
    
afis_analiza_evolutie:
    movl $0, lineIndex
    for3_linii: ;# for(lineIndex=0; lineIndex<m_init; lineIndex++)
        movl lineIndex, %ecx
        cmp %ecx, m
        je inchidere_fisiere

        movl $0, columnIndex
        for3_coloane: ;# for(columnIndex=0; columnIndex<n_init; columnIndex++)
            movl columnIndex, %ecx
            cmp %ecx, n
            je cont_for3_linii

            ;# eax = (lineIndex+1) * (n_init+2) + (columnIndex+1)
            movl lineIndex, %eax
            addl $1, %eax
            movl $0, %edx
            addl $2, n
            mull n
            subl $2, n
            addl columnIndex, %eax
            addl $1, %eax

            lea matrix, %edi
            movl (%edi, %eax, 4), %ebx

            ;# fprintf(descriptor_fisier, &formatFPrintf, var_1, ...)
            pusha
            pushl %ebx
            pushl $formatFPrintf
            pushl outputFileDescriptor
            call fprintf
            add $12, %esp
            popa
            
            pushl $0
            call fflush
            addl $4, %esp
            
            incl columnIndex
            jmp for3_coloane

    cont_for3_linii:
        pusha
        pushl $newLine
        pushl $formatNewline
        pushl outputFileDescriptor
        call fprintf
        add $12, %esp
        popa
        
        pushl $0
        call fflush
        addl $4, %esp
	
        incl lineIndex
        jmp for3_linii
        
inchidere_fisiere:
    ;# inchidere fisier de input
    pushl inputFileDescriptor
    call fclose
    addl $4, %esp
    
    ;# inchidere fisier de output
    pushl outputFileDescriptor
    call fclose
    addl $4, %esp
et_exit:
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80