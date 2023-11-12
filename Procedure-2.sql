CREATE OR REPLACE PROCEDURE AA_MVSIS_ADDREMOVECLIENTD
            (pACAO IN VARCHAR,
             pCODUSUR IN PCUSUARI.CODUSUR%TYPE,
             pCODCLI IN PCCLIENT.CODCLI%TYPE,
             pCODUSURSUB IN PCUSUARI.CODUSUR%TYPE,
             pCAMPOS IN VARCHAR,
             pUTILIZAPAR IN VARCHAR, --ACEITA S OU M
             pTIPOCOD IN VARCHAR DEFAULT 'COD')
IS
    vQTCLI NUMBER;
    vQTCLIPAR NUMBER;
    vQTCLIPAR2 NUMBER;
    vCODUSURPAR PCUSUARI.CODUSUR%TYPE;
    vCODUSURPAR2 PCUSUARI.CODUSUR%TYPE;
    vCODCLI PCCLIENT.CODCLI%TYPE;
    vMESS VARCHAR(500);
    vRCAEXISTE NUMBER;
    vCLIEXISTE NUMBER;
    vQTCLIPCCLIENT1 NUMBER;
    vQTCLIPCCLIENT2 NUMBER;
    vQTCLIPCCLIENT3 NUMBER;
    vCONTADOR_ NUMBER := 0;
    vTEM_ NUMBER := 0;
    vCAMPOOBS PCUSUARI.OBSFORCAVENDAS4%TYPE;
BEGIN
    --DEFININDO MENSAGEM INICIAL
    vMESS := 'SERRO';

    --DEFININDO CODIGO CLIENTE
    IF pTIPOCOD = 'COD' THEN
        vCODCLI := pCODCLI;
    ELSE
        BEGIN
            SELECT CODCLI INTO vCODCLI 
            FROM PCCLIENT 
            WHERE TRIM(REPLACE(TRANSLATE(CGCENT, '.-/', ' '), ' ', '')) = TRIM(REPLACE(TRANSLATE(pCODCLI, '.-/', ' '), ' ', ''));

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                IF vMESS = 'SERRO' THEN
                    vMESS := 'Cliente não encontrado na base de dados';
                ELSE
                    vMESS := vMESS || CHR(10) || 'Cliente não encontrado na base de dados';
                END IF;
        END;

    END IF;

    --CHECANDO SE RCA E CLIENTE EXISTE DENTRO DA BASE DE DADOS
    SELECT COUNT(1) INTO vRCAEXISTE FROM PCUSUARI WHERE CODUSUR IN (pCODUSUR, pCODUSURSUB);

    SELECT COUNT(1) INTO vCLIEXISTE FROM PCCLIENT WHERE CODCLI IN (vCODCLI);

    IF NVL(vRCAEXISTE, 0) IN (0, 1) THEN
        IF vMESS = 'SERRO' THEN
            vMESS := 'RCA(s) não existe(m) na base de dados';
        ELSE
            vMESS := vMESS || CHR(10) || 'RCA(s) não existe(m) na base de dados';
        END IF;
    END IF;

    IF NVL(vCLIEXISTE, 0) = 0 THEN
        IF vMESS = 'SERRO' THEN
            vMESS := 'Ciente não existe na base de dados';
        ELSE
            vMESS := vMESS || CHR(10) || 'Cliente não existe na base de dados';
        END IF;
    END IF;

    --CHECANDO PAR
    IF vMESS <> 'SERRO' THEN
        RAISE_APPLICATION_ERROR(-20000, vMESS);

    ELSIF pUTILIZAPAR = 'S' THEN
        SELECT OBSFORCAVENDAS4 INTO vCAMPOOBS
        FROM PCUSUARI WHERE CODUSUR = pCODUSUR;

        --CONTANDO QUANTOS - TEM NA OBS DO RCA
        FOR I IN 1..LENGTH(vCAMPOOBS) LOOP
            IF SUBSTR(vCAMPOOBS, I, 1) = '-' THEN
                vCONTADOR_ := vCONTADOR_ + 1;
            END IF;
        END LOOP;

        --VERIFICANDO SE TEM - NA OBS DO RCA
        FOR I IN 1..LENGTH(vCAMPOOBS) LOOP
            IF SUBSTR(vCAMPOOBS, I, 1) = '-' THEN
                vTEM_ := 1;
            END IF;
        END LOOP;

        IF NVL((LENGTH(TRIM(TRANSLATE(vCAMPOOBS, '0123456789-',' ')))), 1) = 0 THEN
            IF vTEM_ = 1 THEN
                IF SUBSTR(vCAMPOOBS, 4, 4) = '-' AND
                vCONTADOR_ = 1 THEN
                    SELECT CODUSUR INTO vCODUSURPAR
                    FROM PCUSUARI WHERE CODUSUR = TO_NUMBER(SUBSTR(vCAMPOOBS, 1, 3));

                    SELECT CODUSUR INTO vCODUSURPAR2
                    FROM PCUSUARI WHERE CODUSUR = TO_NUMBER(SUBSTR(vCAMPOOBS, 5, 7));

                END IF;

            ELSE
                SELECT CODUSUR INTO vCODUSURPAR
                FROM PCUSUARI WHERE CODUSUR = TO_NUMBER(vCAMPOOBS);

                vCODUSURPAR2 := 9999;

            END IF;

        ELSE
            vCODUSURPAR := 9999;
            vCODUSURPAR2 := 9999;

        END IF;

        --CONTANDO CLIENTES DO(S) RCA(S)
        ----CLIENTES RCA ORIGINAL
        SELECT COUNT(1) INTO vQTCLI FROM (select codcli from pcusurcli where codusur=pCODUSUR and codcli=pCODCLI
                                          union select codcli from pcclient where codusur1=pCODUSUR and codcli=pCODCLI
                                          union select codcli from pcclient where codusur2=pCODUSUR and codcli=pCODCLI
                                          union select codcli from pcclient where codusur3=pCODUSUR and codcli=pCODCLI);

        ----CLIENTES PAR 1
        SELECT COUNT(1) INTO vQTCLIPAR FROM (select codcli from pcusurcli where codusur=vCODUSURPAR and codcli=pCODCLI
                                          union select codcli from pcclient where codusur1=vCODUSURPAR and codcli=pCODCLI
                                          union select codcli from pcclient where codusur2=vCODUSURPAR and codcli=pCODCLI
                                          union select codcli from pcclient where codusur3=vCODUSURPAR and codcli=pCODCLI);


        ----CLIENTES PAR 2
        SELECT COUNT(1) INTO vQTCLIPAR2 FROM (select codcli from pcusurcli where codusur=vCODUSURPAR2 and codcli=pCODCLI
                                          union select codcli from pcclient where codusur1=vCODUSURPAR2 and codcli=pCODCLI
                                          union select codcli from pcclient where codusur2=vCODUSURPAR2 and codcli=pCODCLI
                                          union select codcli from pcclient where codusur3=vCODUSURPAR2 and codcli=pCODCLI);

    END IF;

    --CHECANDO SE NÃO HOUVE ERROS
    IF vMESS <> 'SERRO' THEN
        RAISE_APPLICATION_ERROR(-20000, vMESS);

    --COMEÇANDO AÇÕES
    ELSE        
        --ADCIONAR CLIENTE
        IF pACAO = 'A' THEN
            IF vQTCLI > 0 THEN
                IF vMESS = 'SERRO' THEN
                    vMESS := 'Ciente já cadastrado para o RCA';
                ELSE
                    vMESS := vMESS || CHR(10) || 'Ciente já cadastrado para o RCA';
                END IF;
            
            END IF;

            IF vMESS = 'SERRO' THEN

                SELECT COUNT(1) INTO vQTCLIPCCLIENT1 FROM PCCLIENT
                WHERE CODCLI=pCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR1<>pCODUSURSUB;

                SELECT COUNT(1) INTO vQTCLIPCCLIENT2 FROM PCCLIENT
                WHERE CODCLI=pCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR2<>pCODUSURSUB;

                SELECT COUNT(1) INTO vQTCLIPCCLIENT3 FROM PCCLIENT
                WHERE CODCLI=pCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR3<>pCODUSURSUB;

                --ADICIONANDO O CLIENTE PARA O RCA PRINCIPAL
                IF vQTCLIPCCLIENT1 = 0 AND
                    SUBSTR(pCAMPOS, 1, 1) = 'S' THEN
                    UPDATE PCCLIENT SET CODUSUR1=pCODUSUR
                    WHERE CODCLI=pCODCLI;

                ELSIF vQTCLIPCCLIENT2 = 0 AND
                    SUBSTR(pCAMPOS, 2, 1) = 'S' THEN
                    UPDATE PCCLIENT SET CODUSUR2=pCODUSUR
                    WHERE CODCLI=pCODCLI;

                ELSIF vQTCLIPCCLIENT3 = 0 AND
                    SUBSTR(pCAMPOS, 3, 1) = 'S' THEN
                    UPDATE PCCLIENT SET CODUSUR3=pCODUSUR
                    WHERE CODCLI=pCODCLI;

                ELSE
                    INSERT INTO PCUSURCLI(CODUSUR, CODCLI, ENVIAFV)
                    VALUES(pCODUSUR, pCODCLI, 'S');

                END IF;
                COMMIT;

                --ADICIONANDO O CLIENTE PARA O VENDEDOR PAR
                IF pUTILIZAPAR = 'S' THEN
                    --PAR1
                    IF vQTCLIPAR = 0 THEN
                        IF NVL(vCODUSURPAR, 0) NOT IN (0, pCODUSUR, 9999) THEN
                            --VERIFICANDO CAMPOS DO CLIENTE NA PCCLIENT, SE EXISTE RCA INATIVO PARA SEREM SUBISTITUIDOS  
                            SELECT COUNT(1) INTO vQTCLIPCCLIENT1 FROM PCCLIENT
                            WHERE CODCLI=pCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR1<>pCODUSURSUB;

                            SELECT COUNT(1) INTO vQTCLIPCCLIENT2 FROM PCCLIENT
                            WHERE CODCLI=pCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR2<>pCODUSURSUB;

                            SELECT COUNT(1) INTO vQTCLIPCCLIENT3 FROM PCCLIENT
                            WHERE CODCLI=pCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR3<>pCODUSURSUB;

                            IF vQTCLIPCCLIENT1 = 0 AND
                                SUBSTR(pCAMPOS, 1, 1) = 'S' THEN
                                UPDATE PCCLIENT SET CODUSUR1=vCODUSURPAR
                                WHERE CODCLI=pCODCLI;

                            ELSIF vQTCLIPCCLIENT2 = 0 AND
                                SUBSTR(pCAMPOS, 2, 1) = 'S' THEN
                                UPDATE PCCLIENT SET CODUSUR2=vCODUSURPAR
                                WHERE CODCLI=pCODCLI;

                            ELSIF vQTCLIPCCLIENT3 = 0 AND
                                SUBSTR(pCAMPOS, 3, 1) = 'S' THEN
                                UPDATE PCCLIENT SET CODUSUR3=vCODUSURPAR
                                WHERE CODCLI=pCODCLI;

                            ELSE
                                INSERT INTO PCUSURCLI(CODUSUR, CODCLI, ENVIAFV)
                                VALUES(vCODUSURPAR, pCODCLI, 'S');
                            END IF;
                        END IF;
                        COMMIT;
                    END IF;

                    IF vQTCLIPAR2 = 0 THEN
                        IF NVL(vCODUSURPAR2, 0) NOT IN (0, pCODUSUR, vCODUSURPAR, 9999) THEN
                            --VERIFICANDO CAMPOS DO CLIENTE NA PCCLIENT, SE EXISTE RCA INATIVO PARA SEREM SUBISTITUIDOS  
                            SELECT COUNT(1) INTO vQTCLIPCCLIENT1 FROM PCCLIENT
                            WHERE CODCLI=pCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR1<>pCODUSURSUB;

                            SELECT COUNT(1) INTO vQTCLIPCCLIENT2 FROM PCCLIENT
                            WHERE CODCLI=pCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR2<>pCODUSURSUB;

                            SELECT COUNT(1) INTO vQTCLIPCCLIENT3 FROM PCCLIENT
                            WHERE CODCLI=pCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR3<>pCODUSURSUB;

                            IF vQTCLIPCCLIENT1 = 0 AND
                                SUBSTR(pCAMPOS, 1, 1) = 'S' THEN
                                UPDATE PCCLIENT SET CODUSUR1=vCODUSURPAR2
                                WHERE CODCLI=pCODCLI;

                            ELSIF vQTCLIPCCLIENT2 = 0 AND
                                SUBSTR(pCAMPOS, 2, 1) = 'S' THEN
                                UPDATE PCCLIENT SET CODUSUR2=vCODUSURPAR2
                                WHERE CODCLI=pCODCLI;

                            ELSIF vQTCLIPCCLIENT3 = 0 AND
                                SUBSTR(pCAMPOS, 3, 1) = 'S' THEN
                                UPDATE PCCLIENT SET CODUSUR3=vCODUSURPAR2
                                WHERE CODCLI=pCODCLI;

                            ELSE
                                INSERT INTO PCUSURCLI(CODUSUR, CODCLI, ENVIAFV)
                                VALUES(vCODUSURPAR2, pCODCLI, 'S');
                            END IF;
                        END IF;
                        COMMIT;
                    END IF;
                END IF;

            ELSE
              RAISE_APPLICATION_ERROR (-20000, vMESS);

            END IF;
        END IF;
    END IF;
END;