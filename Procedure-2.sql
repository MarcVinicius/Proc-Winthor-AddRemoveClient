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
    vCODUSUR1 PCCLIENT.CODUSUR1%TYPE;
    vCODUSUR2 PCCLIENT.CODUSUR2%TYPE;
    vCODUSUR3 PCCLIENT.CODUSUR3%TYPE;
    vQTCLI3315RCA NUMBER;
    vQTCLI3315PAR1 NUMBER;
    vQTCLI3315PAR2 NUMBER;
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
                    vMESS := 'CNPJ não cadastrado';
                ELSE
                    vMESS := vMESS || CHR(10) || 'CNPJ não cadastrado';
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

    --CONTANDO CLIENTES DO RCA
    ----CLIENTES RCA ORIGINAL
    SELECT COUNT(1) INTO vQTCLI FROM (select codcli from pcusurcli where codusur=pCODUSUR and codcli=vCODCLI
                                    union select codcli from pcclient where codusur1=pCODUSUR and codcli=vCODCLI
                                     union select codcli from pcclient where codusur2=pCODUSUR and codcli=vCODCLI
                                    union select codcli from pcclient where codusur3=pCODUSUR and codcli=vCODCLI);

    --CHECANDO PAR
    IF vMESS <> 'SERRO' THEN
        RAISE_APPLICATION_ERROR(-20000, vMESS);

    ELSIF UPPER(pUTILIZAPAR) = 'S' THEN
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

        --CONTANDO CLIENTES DO(S) RCA(S) PARES
        ----CLIENTES PAR 1
        SELECT COUNT(1) INTO vQTCLIPAR FROM (select codcli from pcusurcli where codusur=vCODUSURPAR and codcli=vCODCLI
                                          union select codcli from pcclient where codusur1=vCODUSURPAR and codcli=vCODCLI
                                          union select codcli from pcclient where codusur2=vCODUSURPAR and codcli=vCODCLI
                                          union select codcli from pcclient where codusur3=vCODUSURPAR and codcli=vCODCLI);


        ----CLIENTES PAR 2
        SELECT COUNT(1) INTO vQTCLIPAR2 FROM (select codcli from pcusurcli where codusur=vCODUSURPAR2 and codcli=vCODCLI
                                          union select codcli from pcclient where codusur1=vCODUSURPAR2 and codcli=vCODCLI
                                          union select codcli from pcclient where codusur2=vCODUSURPAR2 and codcli=vCODCLI
                                          union select codcli from pcclient where codusur3=vCODUSURPAR2 and codcli=vCODCLI);

    END IF;

    --CHECANDO SE não HOUVE ERROS
    IF vMESS <> 'SERRO' THEN
        RAISE_APPLICATION_ERROR(-20000, vMESS);

    --COME?ANDO A??ES
    ELSE
        --ADCIONAR CLIENTE
        IF pACAO = 'A' THEN
            IF vQTCLI > 0 THEN
                IF vMESS = 'SERRO' THEN
                    vMESS := 'Ciente ja cadastrado para o RCA';
                ELSE
                    vMESS := vMESS || CHR(10) || 'Ciente ja cadastrado para o RCA';
                END IF;

            END IF;

            IF vMESS = 'SERRO' THEN

                SELECT COUNT(1) INTO vQTCLIPCCLIENT1 FROM PCCLIENT
                WHERE CODCLI=vCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR1<>pCODUSURSUB;

                SELECT COUNT(1) INTO vQTCLIPCCLIENT2 FROM PCCLIENT
                WHERE CODCLI=vCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR2<>pCODUSURSUB;

                SELECT COUNT(1) INTO vQTCLIPCCLIENT3 FROM PCCLIENT
                WHERE CODCLI=vCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR3<>pCODUSURSUB;

                --ADICIONANDO O CLIENTE PARA O RCA PRINCIPAL
                IF vQTCLIPCCLIENT1 = 0 AND
                    SUBSTR(pCAMPOS, 1, 1) = 'S' THEN
                    UPDATE PCCLIENT SET CODUSUR1=pCODUSUR
                    WHERE CODCLI=vCODCLI;

                ELSIF vQTCLIPCCLIENT2 = 0 AND
                    SUBSTR(pCAMPOS, 2, 1) = 'S' THEN
                    UPDATE PCCLIENT SET CODUSUR2=pCODUSUR
                    WHERE CODCLI=vCODCLI;

                ELSIF vQTCLIPCCLIENT3 = 0 AND
                    SUBSTR(pCAMPOS, 3, 1) = 'S' THEN
                    UPDATE PCCLIENT SET CODUSUR3=pCODUSUR
                    WHERE CODCLI=vCODCLI;

                ELSE
                    INSERT INTO PCUSURCLI(CODUSUR, CODCLI, ENVIAFV)
                    VALUES(pCODUSUR, vCODCLI, 'S');

                END IF;
                COMMIT;

                --ADICIONANDO O CLIENTE PARA O VENDEDOR PAR
                IF UPPER(pUTILIZAPAR) = 'S' THEN
                    --PAR1
                    IF vQTCLIPAR = 0 THEN
                        IF NVL(vCODUSURPAR, 0) NOT IN (0, pCODUSUR, 9999) THEN
                            --VERIFICANDO CAMPOS DO CLIENTE NA PCCLIENT, SE EXISTE RCA INATIVO PARA SEREM SUBISTITUIDOS
                            SELECT COUNT(1) INTO vQTCLIPCCLIENT1 FROM PCCLIENT
                            WHERE CODCLI=vCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR1<>pCODUSURSUB;

                            SELECT COUNT(1) INTO vQTCLIPCCLIENT2 FROM PCCLIENT
                            WHERE CODCLI=vCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR2<>pCODUSURSUB;

                            SELECT COUNT(1) INTO vQTCLIPCCLIENT3 FROM PCCLIENT
                            WHERE CODCLI=vCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR3<>pCODUSURSUB;

                            IF vQTCLIPCCLIENT1 = 0 AND
                                SUBSTR(pCAMPOS, 1, 1) = 'S' THEN
                                UPDATE PCCLIENT SET CODUSUR1=vCODUSURPAR
                                WHERE CODCLI=vCODCLI;

                            ELSIF vQTCLIPCCLIENT2 = 0 AND
                                SUBSTR(pCAMPOS, 2, 1) = 'S' THEN
                                UPDATE PCCLIENT SET CODUSUR2=vCODUSURPAR
                                WHERE CODCLI=vCODCLI;

                            ELSIF vQTCLIPCCLIENT3 = 0 AND
                                SUBSTR(pCAMPOS, 3, 1) = 'S' THEN
                                UPDATE PCCLIENT SET CODUSUR3=vCODUSURPAR
                                WHERE CODCLI=vCODCLI;

                            ELSE
                                INSERT INTO PCUSURCLI(CODUSUR, CODCLI, ENVIAFV)
                                VALUES(vCODUSURPAR, vCODCLI, 'S');
                            END IF;
                        END IF;
                        COMMIT;
                    END IF;

                    --PAR2
                    IF vQTCLIPAR2 = 0 THEN
                        IF NVL(vCODUSURPAR2, 0) NOT IN (0, pCODUSUR, vCODUSURPAR, 9999) THEN
                            --VERIFICANDO CAMPOS DO CLIENTE NA PCCLIENT, SE EXISTE RCA INATIVO PARA SEREM SUBISTITUIDOS
                            SELECT COUNT(1) INTO vQTCLIPCCLIENT1 FROM PCCLIENT
                            WHERE CODCLI=vCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR1<>pCODUSURSUB;

                            SELECT COUNT(1) INTO vQTCLIPCCLIENT2 FROM PCCLIENT
                            WHERE CODCLI=vCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR2<>pCODUSURSUB;

                            SELECT COUNT(1) INTO vQTCLIPCCLIENT3 FROM PCCLIENT
                            WHERE CODCLI=vCODCLI AND CODUSUR1 IN (SELECT CODUSUR FROM PCUSUARI WHERE DTTERMINO IS NULL) AND CODUSUR3<>pCODUSURSUB;


                            IF vQTCLIPCCLIENT1 = 0 AND
                                SUBSTR(pCAMPOS, 1, 1) = 'S' THEN
                                UPDATE PCCLIENT SET CODUSUR1=vCODUSURPAR2
                                WHERE CODCLI=vCODCLI;

                            ELSIF vQTCLIPCCLIENT2 = 0 AND
                                SUBSTR(pCAMPOS, 2, 1) = 'S' THEN
                                UPDATE PCCLIENT SET CODUSUR2=vCODUSURPAR2
                                WHERE CODCLI=vCODCLI;

                            ELSIF vQTCLIPCCLIENT3 = 0 AND
                                SUBSTR(pCAMPOS, 3, 1) = 'S' THEN
                                UPDATE PCCLIENT SET CODUSUR3=vCODUSURPAR2
                                WHERE CODCLI=vCODCLI;

                            ELSE
                                INSERT INTO PCUSURCLI(CODUSUR, CODCLI, ENVIAFV)
                                VALUES(vCODUSURPAR2, vCODCLI, 'S');
                            END IF;
                        END IF;
                        COMMIT;
                    END IF;
                END IF;

            ELSE
              RAISE_APPLICATION_ERROR (-20000, vMESS);

            END IF;

        ELSE
            IF vQTCLI <= 0 THEN
                IF vMESS = 'SERRO' THEN
                    vMESS := 'não existe clientes para esse RCA';
                ELSE
                    vMESS := vMESS || CHR(10) || 'não existe clientes para esse RCA';
                END IF;

            END IF;

            IF vMESS = 'SERRO' THEN
                --BUSCANDO CAMPOS RCA DO CLIENTE NA PCLCIENT
                SELECT CODUSUR1 INTO vCODUSUR1 FROM PCCLIENT
                WHERE CODCLI = vCODCLI;

                SELECT CODUSUR2 INTO vCODUSUR2 FROM PCCLIENT
                WHERE CODCLI = vCODCLI;

                SELECT CODUSUR3 INTO vCODUSUR3 FROM PCCLIENT
                WHERE CODCLI = vCODCLI;

                --CONTANDO CLIENTES NA 3315
                SELECT COUNT(1) INTO vQTCLI3315RCA FROM PCUSURCLI
                WHERE CODCLI = vCODCLI
                AND CODUSUR = pCODUSUR;

                --TIRANDO O CLIENTE DO RCA PRINCIPAL
                ----CAMPO CODUSUR1
                IF vCODUSUR1 = pCODUSUR THEN
                    UPDATE PCCLIENT SET CODUSUR1 = pCODUSURSUB
                    WHERE CODCLI = vCODCLI;

                END IF;

                ----CAMPO CODUSUR2 SE O CAMPO CODUSUR1 TIVER PREENCHIDO
                IF (vCODUSUR2 = pCODUSUR) AND
                    (vCODUSUR1 IS NOT NULL) THEN
                        UPDATE PCCLIENT SET CODUSUR2 = NULL
                        WHERE CODCLI = vCODCLI;

                ----CAMPO CODUSUR2 SE O CAMPO CODUSUR1 ESTIVER VAZIO
                ELSE
                    IF vCODUSUR2 = pCODUSUR THEN
                        UPDATE PCCLIENT SET CODUSUR2 = NULL, CODUSUR1 = pCODUSURSUB
                        WHERE CODCLI = vCODCLI;

                    END IF;
                END IF;

                ----CAMPO CODUSUR3 SE O CAMPO CODUSUR1 TIVER PREENCHIDO
                IF (vCODUSUR3 = pCODUSUR) AND
                    (vCODUSUR1 IS NOT NULL) THEN
                        UPDATE PCCLIENT SET CODUSUR3 = NULL
                        WHERE CODCLI = vCODCLI;

                ----CAMPO CODUSUR3 SE O CAMPO CODUSUR1 ESTIVER VAZIO
                ELSE
                    IF vCODUSUR3 = pCODUSUR THEN
                        UPDATE PCCLIENT SET CODUSUR3 = NULL, CODUSUR1 =pCODUSURSUB
                        WHERE CODCLI = vCODCLI;

                    END IF;
                END IF;

                --TIRANDO O CLIENTE DA 3315
                IF NVL(vQTCLI3315RCA, 0) > 0 THEN
                    DELETE FROM PCUSURCLI
                    WHERE CODCLI = vCODCLI
                    AND CODUSUR = pCODUSUR;

                END IF;
                COMMIT;

                --TIRANDO CLIENTE DO RCA SUBSTITUTO 1
                IF UPPER(pUTILIZAPAR) = 'S' THEN
                    --REMOVENDO DO O RCA PAR1
                    IF NVL(vCODUSURPAR, 0) NOT IN (0, pCODUSUR, pCODUSURSUB, 9999) THEN
                        --BUSCANDO CAMPOS RCA DA PCCLIENT
                        SELECT CODUSUR1 INTO vCODUSUR1 FROM PCCLIENT
                        WHERE CODCLI = vCODCLI;

                        SELECT CODUSUR2 INTO vCODUSUR2 FROM PCCLIENT
                        WHERE CODCLI = vCODCLI;

                        SELECT CODUSUR3 INTO vCODUSUR3 FROM PCCLIENT
                        WHERE CODCLI = vCODCLI;

                        --CONTANDO CLIENTES NA 3315
                        SELECT COUNT(1) INTO vQTCLI3315PAR1 FROM PCUSURCLI
                        WHERE CODCLI = vCODCLI
                        AND CODUSUR = vCODUSURPAR;

                        --CAMPO CODUSUR1
                        IF vCODUSUR1 = vCODUSURPAR THEN
                            UPDATE PCCLIENT SET CODUSUR1 = pCODUSURSUB
                            WHERE CODCLI = vCODCLI;

                        END IF;

                        ----CAMPO CODUSUR2 SE O CAMPO CODUSUR1 TIVER PREENCHIDO
                        IF (vCODUSUR2 = vCODUSURPAR) AND
                            (vCODUSUR1 IS NOT NULL) THEN
                                UPDATE PCCLIENT SET CODUSUR2 = NULL
                                WHERE CODCLI = vCODCLI;

                        ----CAMPO CODUSUR2 SE O CAMPO CODUSUR1 TIVER VAZIO
                        ELSE
                            IF vCODUSUR2 = vCODUSURPAR THEN
                                UPDATE PCCLIENT SET CODUSUR2 = NULL, CODUSUR1 = pCODUSURSUB
                                WHERE CODCLI = vCODCLI;

                            END IF;
                        END IF;

                        ----CAMPO CODUSUR3 SE O CAMPO CODUSUR1 TIVER PREENCHIDO
                        IF (vCODUSUR3 = vCODUSURPAR) AND
                            (vCODUSUR1 IS NOT NULL) THEN
                                UPDATE PCCLIENT SET CODUSUR3 = NULL
                                WHERE CODCLI = vCODCLI;

                        ----CAMPO CODUSUR3 SE O CAMPO CODUSUR1 TIVER VAZIO
                        ELSE
                            IF vCODUSUR3 = vCODUSURPAR THEN
                                UPDATE PCCLIENT SET CODUSUR3 = NULL, CODUSUR1 = pCODUSURSUB
                                WHERE CODCLI = vCODCLI;
                            END IF;

                        END IF;

                        --TIRANDO DA 3315
                        IF NVL(vQTCLI3315PAR1, 0) > 0 THEN
                            DELETE FROM PCUSURCLI
                            WHERE CODCLI = vCODCLI
                            AND CODUSUR = vCODUSURPAR;

                        END IF;
                        COMMIT;
                    END IF;

                    --REMOVENDO DO RCA PAR 2
                    IF NVL(vCODUSURPAR2, 0) NOT IN (0, pCODUSUR, pCODUSURSUB, 9999) THEN
                        --BUSCANDO CAMPOS RCA DA PCCLIENT
                        SELECT CODUSUR1 INTO vCODUSUR1 FROM PCCLIENT
                        WHERE CODCLI = vCODCLI;

                        SELECT CODUSUR2 INTO vCODUSUR2 FROM PCCLIENT
                        WHERE CODCLI = vCODCLI;

                        SELECT CODUSUR3 INTO vCODUSUR3 FROM PCCLIENT
                        WHERE CODCLI = vCODCLI;

                        --CONTANDO CLIENTES NA 3315
                        SELECT COUNT(1) INTO vQTCLI3315PAR2 FROM PCUSURCLI
                        WHERE CODCLI = vCODCLI
                        AND CODUSUR = vCODUSURPAR2;

                        --CAMPO CODUSUR1
                        IF vCODUSUR1 = vCODUSURPAR2 THEN
                            UPDATE PCCLIENT SET CODUSUR1 = pCODUSURSUB
                            WHERE CODCLI = vCODCLI;

                        END IF;

                        ----CAMPO CODUSUR2 SE O CAMPO CODUSUR1 TIVER PREENCHIDO
                        IF (vCODUSUR2 = vCODUSURPAR2) AND
                            (vCODUSUR1 IS NOT NULL) THEN
                                UPDATE PCCLIENT SET CODUSUR2 = NULL
                                WHERE CODCLI = vCODCLI;

                        ----CAMPO CODUSUR2 SE O CAMPO CODUSUR1 TIVER VAZIO
                        ELSE
                            IF vCODUSUR2 = vCODUSURPAR2 THEN
                                UPDATE PCCLIENT SET CODUSUR2 = NULL, CODUSUR1 = pCODUSURSUB
                                WHERE CODCLI = vCODCLI;

                            END IF;
                        END IF;

                        ----CAMPO CODUSUR3 SE O CAMPO CODUSUR1 TIVER PREENCHIDO
                        IF (vCODUSUR3 = vCODUSURPAR2) AND
                            (vCODUSUR1 IS NOT NULL) THEN
                                UPDATE PCCLIENT SET CODUSUR3 = NULL
                                WHERE CODCLI = vCODCLI;

                        ----CAMPO CODUSUR3 SE O CAMPO CODUSUR1 TIVER VAZIO
                        ELSE
                            IF vCODUSUR3 = vCODUSURPAR2 THEN
                                UPDATE PCCLIENT SET CODUSUR3 = NULL, CODUSUR1 = pCODUSURSUB
                                WHERE CODCLI = vCODCLI;
                            END IF;

                        END IF;

                        --TIRANDO DA 3315
                        IF NVL(vQTCLI3315PAR2, 0) > 0 THEN
                            DELETE FROM PCUSURCLI
                            WHERE CODCLI = vCODCLI
                            AND CODUSUR = vCODUSURPAR2;

                        END IF;
                        COMMIT;
                    END IF;

                END IF;

            END IF;

        END IF;
    END IF;
END;