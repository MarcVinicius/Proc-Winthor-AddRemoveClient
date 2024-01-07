from msilib import text
from tela import Ui_tela
from PyQt5 import QtCore, QtGui, QtWidgets
#import cx_Oracle
import sys
import os

#Classes telas
class tela_princ(QtWidgets.QApplication, Ui_tela):
    def __init__(self):
        super().__init__()
        self.setup(self)

#=w=w=w=w=w=w=w=wSPOOL=w=w=w=w=w=w=w=w
#CRIAR ARQUIVO DE CONFIGURACAO AO ABRIR ROTINA PELA PRIMEIRA VEZ
def criar_spool_f():
    addrem = 'add'
    codcnpj = 'cod'
    rcasub = str(1)
    rca1 = 's'
    rca2 = 's'
    rca3 = 'n'
    par = 'n'

    with open("C:\spoolmain\conf.ini", "w") as arquivo:
        arquivo.write(addrem+"\n"+codcnpj+"\n"+rcasub+"\n"+rca1+"\n"+rca2+"\n"+rca3+"\n"+par)

#CARREGAR CONFIGURAÇÕES JÁ SALVAS DO SPOOL
def carregar_spool_f():
    with open(r"C:\spoolmain\conf.ini", "r") as arquivo:
        #CARREGANDO VARIAVEIS DO ARQUIVO SPOOL
        conff = arquivo.readlines()
        addrem = conff[0].replace('\n', '')
        codcnpj = conff[1].replace('\n', '')
        rcasub = conff[2].replace('\n', '')
        rca1 = conff[3].replace('\n', '')
        rca2 = conff[4].replace('\n', '')
        rca3 = conff[5].replace('\n', '')
        par = conff[6].replace('\n', '')

        #CHECANDO SE VARIAVEIS SAO DO TIPO CORRETO
        if addrem not in ('add', 'rem'):
            addrem = 'add'

        if codcnpj not in ('cod', 'cnpj'):
            codcnpj = 'cod'

        if int(rcasub) not in range(1, 9999999999999):
            rcasub = '1'

        if rca1 not in ('s', 'n'):
            rca1 = 's'

        if rca2 not in ('s', 'n'):
            rca2 = 's'

        if rca3 not in ('s', 'n'):
            rca3 = 'n'

        if par not in ('s', 'n'):
            par = 'n'
        
        #SETANDO VARIEDADES NA TELA
        #ACAO, SE VAI SER ADICIONAR OU REMOVER
        if addrem == 'add':
            uitela.add_rbtt.setChecked(True)

        else:
            uitela.rem_rbtt.setChecked(True)

        #VALIDACAO DO CLIENTE, SE VAI SER POR CODIGO OU CNPJ
        if codcnpj == 'cod':
            uitela.codcli_rbtt.setChecked(True)

        else:
            uitela.cnpj_rbtt.setChecked(True)
        
        #RCA SUBSTITUO
        if rcasub.isnumeric():
            uitela.rcasub_ln.setText(str(rcasub))

        #CHECK BOX'S DOS CAMPOS DE RCA E UTILIZA PAR
        if rca1 == 's':
            uitela.rca1_302_cbox.setChecked(True)
        if rca2 == 's':
            uitela.rca2_302_cbox.setChecked(True)
        if rca3 == 's':
            uitela.rca3_302_cbox.setChecked(True)
        if par == 's':
            uitela.util_par_cbox.setChecked(True)

#SALVAR CONFIGURAÇÕES DO SPOOL AO FECHAR A ROTINA
def salvar_spool_f():
    addrem = ''
    codcnpj = ''
    rcasub = ''
    rca1 = ''
    rca2 = ''
    rca3 = ''
    par = ''

    if uitela.rem_rbtt.isChecked() == True:
        addrem = 'rem'

    else:
        addrem = 'add'

    if uitela.cnpj_rbtt.isChecked() == True:
        codcnpj = 'cnpj'

    else:
        codcnpj = 'cod'

    if uitela.rcasub_ln.text().isnumeric():
        if int(uitela.rcasub_ln.text()) > 0:
            rcasub = uitela.rcasub_ln.text()

    else:
        rcasub = '1'

    if uitela.rca1_302_cbox.isChecked() == True:
        rca1 = 's'

    else:
        rca1 = 'n'

    if uitela.rca2_302_cbox.isChecked() == True:
        rca2 = 's'

    else:
        rca2 = 'n'

    if uitela.rca3_302_cbox.isChecked() == True:
        rca3 = 's'

    else:
        rca3 = 'n'

    if uitela.util_par_cbox.isChecked() == True:
        par = 's'

    else:
        par = 'n'

    with open("c:\spoolmain\conf.ini", "w") as arquivo:
        arquivo.write(addrem+"\n"+codcnpj+"\n"+rcasub+"\n"+rca1+"\n"+rca2+"\n"+rca3+"\n"+par)
        
def checar_spool_f():
    #pasta =
    arq = r"c:\spoolmain\conf.ini"

    #pastaexiste
    arqexiste = os.path.exists(arq)

    if not arqexiste:
        criar_spool_f()

    else:
        carregar_spool_f()

    uitela.fechar_btt.clicked.connect(salvar_spool_f)
    uitela.fechar_btt.clicked.connect(tela.close)

if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    #TELA PRINCIPAL
    tela = QtWidgets.QWidget()
    uitela = Ui_tela()
    uitela.setupUi(tela)
    tela.show()
    #FUNCOES
    checar_spool_f()
    sys.exit(app.exec_())