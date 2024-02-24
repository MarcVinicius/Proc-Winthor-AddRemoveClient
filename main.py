from msilib import text
from tela import Ui_tela
from PyQt5 import QtCore, QtGui, QtWidgets
from PyQt5.QtCore import Qt
import cx_Oracle
import sys
import os

#CLASSES TELAS
class tela_princ(QtWidgets.QApplication, QtWidgets.QWidget, Ui_tela):
    def __init__(self):
        super().__init__()
        self.setup(self)

#PARAMETROS PARA CONEXAO COM O BANCO, BANCO DE TESTE, DESCARTADA POIS FOI USADA PARA TESTES
with open("conexaobd.txt", 'r') as conexaobd:
    conn_linhas = conexaobd.readlines()
    senhabd = conn_linhas[0].replace('\n', '')
    aliasbd = conn_linhas[1].replace('\n', '')
    usuariobd = conn_linhas[2].replace('\n', '')

#PEGANDO OS ARGUMENTOS PASSADOS PELA ROTINA
"""aplicacao = sys.argv[0]
usuariowt = sys.argv[1]
senhabd = sys.argv[2]
aliasbd = sys.argv[3]
usuariobd = sys.argv[4]
codrotina = sys.argv[5]"""

#TELA DE MENSAGENS(MESSAGE BOX)
class mess_box:
    def __init__(self, titulo, texto, cor_btt):
        self.titulo = titulo
        self.texto = texto
        self.cor_btt = cor_btt
        self.set_color()

    def set_color(self):
        msg = QtWidgets.QMessageBox()
        msg.setWindowTitle(self.titulo)
        msg.setText(self.texto)
        msg.setStyleSheet("QMessageBox{background-color: lightblue;}\n"
        "QPushButton"+'{'+f"background-color: rgb({self.cor_btt[0]}, {self.cor_btt[1]}, {self.cor_btt[2]});"+"}")
        if self.titulo == 'ERRO':
            msg.setIcon(QtWidgets.QMessageBox.Warning)
        elif self.titulo == 'SUCESSO':
            msg.setIcon(QtWidgets.QMessageBox.Information)
        x = msg.exec_()

#CONEXAO COM O BANCO DE DADOS
class conexao():
    def __init__(self, comando, alias=aliasbd, user=usuariobd, password=senhabd):
        self.conn = cx_Oracle.connect(user=user, password=password, dsn=alias)
        self.comando = comando

    def insert_update(self):
        cursor = self.conn.cursor()
        cursor.execute(self.comando)
        self.conn.commit()
        self.conn.close()

    def fetchall(self):
        cursor = self.conn.cursor()
        consulta = cursor.execute(self.comando)
        consulta_fe = consulta.fetchall()
        return consulta_fe
    
    def fetchone(self):
        cursor = self.conn.cursor()
        consulta = cursor.execute(self.comando)
        consulta_fo = consulta.fetchone()
        return consulta_fo
    
    def call_proc_7(self, par1, par2, par3, par4, par5, par6, par7):
        cursor = self.conn.cursor()
        #codigo = cursor.callproc(self.comando, [par1, par2, par3, par4, par5])
        cursor.callproc('AA_MVSIS_ADDREMOVECLIENTD', (par1, par2, par3, par4, par5, par6, par7))
        cursor.close()
        self.conn.close()

#VALIDANDO DATA PARA LICENCA DA ROTINA
        
#data = conexao("""SELECT CASE WHEN TRUNC(SYSDATE) <= '30/JUN/2024' THEN 'SIM' ELSE 'NAO' END DATA FROM DUAL """).fetchone()

data = ('SIM')
codrotina = 530

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

    #C:\spoolmain\conf.ini <- caminho antigo, usado nos testes

    with open(f"C:\WinThor\Spool\{codrotina}.ini", "w") as arquivo:
        arquivo.write(addrem+"\n"+codcnpj+"\n"+rcasub+"\n"+rca1+"\n"+rca2+"\n"+rca3+"\n"+par)

#CARREGAR CONFIGURAÇÕES JÁ SALVAS DO SPOOL
def carregar_spool_f():
    with open(rf"C:\WinThor\Spool\{codrotina}.ini", "r") as arquivo:
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
        addrem = 'add' if addrem not in ('add', 'rem') else addrem
        
        codcnpj = 'cod' if codcnpj not in ('cod', 'cnpj') else codcnpj

        if rcasub.isnumeric():
            rcasub = '1' if int(rcasub) not in range(1, 9999999999999) else rcasub

        else:
            rcasub = '1'

        rca1 = 's' if rca1 not in ('s', 'n') else rca1

        rca2 = 's' if rca2 not in ('s', 'n') else rca2
        
        rca3 = 'n' if rca3 not in ('s', 'n') else rca3

        par = 'n' if par not in ('s', 'n') else par
        
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

    with open(f"C:\WinThor\Spool\{codrotina}.ini", "w") as arquivo:
        arquivo.write(addrem+"\n"+codcnpj+"\n"+rcasub+"\n"+rca1+"\n"+rca2+"\n"+rca3+"\n"+par)
        
def checar_spool_f():
    #pasta =
    arq = rf"C:\WinThor\Spool\{codrotina}.ini"

    #pastaexiste
    arqexiste = os.path.exists(arq)

    if not arqexiste:
        criar_spool_f()

    else:
        carregar_spool_f()

    uitela.fechar_btt.clicked.connect(salvar_spool_f)
    uitela.fechar_btt.clicked.connect(tela.close)
    uitela.x_btt.clicked.connect(salvar_spool_f)

#TESTANDO CONEXÃO COM O BANCO
#print(conexao("SELECT matricula FROM PCEMPR WHERE ROWNUM < 2").fetchall())
    
#ATUALIZANDO DADOS DA LINE EDIT
def atualizar_ln_f():
    def atualizar_f(campo1, campo2, tabela, cod, lineedit):
        consulta = []
        if cod.isnumeric():
            consulta = conexao(f"""SELECT {campo1}, {campo2} FROM {tabela} WHERE {campo1} = {int(cod)}""").fetchone()
            if consulta == None:
                consulta = []

        if len(consulta) > 0:
            lineedit.setText(consulta[1])
            lineedit.setStyleSheet("Background-color: rgb(190, 190, 190);")
            lineedit.setReadOnly(True)

        else:
            lineedit.setText('')
            lineedit.setStyleSheet("Background color: rgb(255, 255, 255);")
            lineedit.setReadOnly(True)

    def atualizar_cnpj_f(campo1, campo2, tabela, cod, lineedit):
        consulta = []
        if cod.isnumeric():
            consulta = conexao(f"""SELECT {campo1}, {campo2} FROM {tabela} WHERE REPLACE(REPLACE(REPLACE({campo1}, '.', ''), '/', ''), '-', '') = TO_CHAR({str(cod)})""").fetchone()
            if consulta == None:
                consulta = []

        if len(consulta) > 0:
            lineedit.setText(consulta[1])
            lineedit.setStyleSheet("Background-color: rgb(190, 190, 190);")
            lineedit.setReadOnly(True)

        else:
            lineedit.setText('')
            lineedit.setStyleSheet("Background color: rgb(255, 255, 255);")
            lineedit.setReadOnly(False)

    uitela.rca_ln.editingFinished.connect(lambda: atualizar_f('CODUSUR', 'NOME', 'PCUSUARI', uitela.rca_ln.text(), uitela.rca_nome_ln))
    uitela.rcasub_ln.editingFinished.connect(lambda: atualizar_f('CODUSUR', 'NOME', 'PCUSUARI', uitela.rcasub_ln.text(), uitela.rcasub_nomeln))
    uitela.codcli_ln.editingFinished.connect(lambda: atualizar_f('CODCLI', 'CLIENTE', 'PCCLIENT', uitela.codcli_ln.text(), uitela.cliente_ln))
    #PESQUISANDO POR CNPJ
    uitela.cnpjcli_ln.editingFinished.connect(lambda: atualizar_cnpj_f('CGCENT', 'CLIENTE', 'PCCLIENT', uitela.cnpjcli_ln.text().replace('/', '').replace('-', '').replace('.', ''), uitela.cliente_ln))

    if uitela.rcasub_ln.text() != None:
        if uitela.rcasub_ln.text().isnumeric():
            atualizar_f('CODUSUR', 'NOME', 'PCUSUARI', uitela.rcasub_ln.text(), uitela.rcasub_nomeln)

def executar_procedure_f():
    #CRIANDO VARIAVEIS
    campos = ''
    acao = ''
    validacao_cli = ''
    rca1 = uitela.rca_ln.text()
    rca_sub = uitela.rcasub_ln.text()
    codcli = ''
    par = ''
    campos_list = [uitela.rca1_302_cbox.isChecked(), uitela.rca2_302_cbox.isChecked(), uitela.rca3_302_cbox.isChecked()]
    
    if uitela.add_rbtt.isChecked():
        acao = 'A'

    else:
        acao = 'R'

    if uitela.codcli_rbtt.isChecked():
        validacao_cli = 'COD'
        codcli = uitela.codcli_ln.text()

    else:
        validacao_cli = 'CNPJ'
        codcli = uitela.cnpjcli_ln.text()

    if uitela.util_par_cbox.isChecked():
        par = 'S'

    else:
        par = 'N'

    for i in campos_list:
        if i == True:
            campos += 'S'

        else:
            campos += 'N'

    if '' not in (uitela.rca_nome_ln.text(), uitela.rcasub_nomeln.text(), uitela.cliente_ln.text()):
        try:
           conexao('procedure').call_proc_7(acao, rca1, codcli, rca_sub, campos, par, validacao_cli)
           
           acao_t = '' #TEXTO MUDA CASO FOR ADICIONAR OU REMOVER
           
           acao_t = 'adicionado' if acao == 'A' else 'Removido'

           mensagem = f'Cliente {acao_t} com sucesso'
           mess_box('SUCESSO', mensagem, (0, 255, 0))
            
        except Exception as erro:
            print('Um erro ocorreu: ', erro)
            mensagem = 'Um erro ocorreu: '+str(erro)
            mess_box('ERRO', mensagem, (255, 0, 0))
         
if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    #TELA PRINCIPAL
    tela = QtWidgets.QWidget()
    uitela = Ui_tela()
    uitela.setupUi(tela)
    tela.show()
    #validando licenca da rotina
    if data[0] == 'NAO':
        uitela.rotina_lb.setText('Rotina Expirada')
        mensagem = 'Licença da rotina expirada, contate o administrador do sistema'
        mess_box('ERRO DE LICENÇA', mensagem, (255, 0, 0))
        uitela.wid_botoes.setEnabled(False)
        uitela.twid_tabela.setEnabled(False)
    
    elif data[0] == 'SIM':
        nomerotina = conexao(f"""SELECT NOMEROTINA FROM PCROTINA WHERE CODIGO = {int(codrotina)}""").fetchone()
        if nomerotina != None:
            uitela.rotina_lb.setText(str(codrotina)+ ' - ' +nomerotina[0])
        uitela.wid_botoes.setEnabled(True)
        uitela.twid_tabela.setEnabled(True)

    #FUNCOES
    checar_spool_f()
    atualizar_ln_f()
    uitela.executar_btt.clicked.connect(executar_procedure_f)
    sys.exit(app.exec_())