# HillClimbGodot
Implementando mecânica da suspensão do Hill Climb Racing na Godot 3.2.3

## Problema
<p align="justify">
	Há um tempo atrás quis replicar uma mecânica do jogo Hill Climb Racing para entender como funcionava, porém, me deparei com um problema. 
	A Godot Engine na versão 3.2.3 não possui um nó especifico responsável por simular uma suspensão de um veículo em 2D, diferentemente da 
	Unity que tem um componente especifico para essa função. 
</p>
<p align="justify">
	Então, como aplicar a física o mais próximo possível a uma suspensão?! Fui pesquisar sobre e vi que nessa versão da Engine, existem três 
	tipos de nós para lidar com molas e afins. Temos o DampedSpringJoint2D, GrooveJoint2D e o PinJoint2D. O primeiro simula uma espécie de 
	elástico de escritório, também chamado de “gominha”. 
</p>
<p align="justify">
	Este pode se movimentar para o eixo X e Y, o que não o torna bom para simular uma suspensão que só se contrai na vertical. O Groove Joint 
	já é diferente. O comportamento dele é como uma espécie de fenda, onde o corpo só pode se movimentar linearmente. E por ultimo o Pin Joint 
	que será explicado abaixo.
</p>

<p align="center">
	<img src="https://github.com/rlcarneiro97/HillClimbGodot/blob/main/readme/2193454_1.jpg" width="400">
</p>

<p align="justify">
	Vamos supor que nós temos um Papai Noel com uma mola presa em baixo dele. Se você prender a mola ao chão com uma mão, olhar por cima, e 
	com a outra mão mexer o “bom velhinho” para os lados, você verá o funcionamento do Pin Joint. Ele nada mais é do que uma mola presa a um 
	ponto no espaço, onde ela se conecta a outro objeto, e esse objeto conectado recebe amortecimento do eixo X ou Y, semelhante ao Damped Spring. 
	Ele possui também a possibilidade de deixar a rigidez muito alta, o que permite ser um elo entre objetos, como uma dobradiça.
</p>

## Unindo Recursos
<p align="justify">
	Alguns já devem ter percebido que há a possibilidade de unir alguns dos nós já citados, então porque não verificar quais nós devem 
	ser combinados?! Ou melhor, porque não usar uma forma de limitar a mola com um Groove Joint?! E é justamente esse o caminho pelo 
	qual se deve seguir.
</p>
<p align="justify">
	De início tentei conectar só um Groove pra cada roda. Esse nó unia o Carro a Roda e limitava sua movimentação só na 
	vertical. Como não há amortecimento, eu coloquei um Pin Joint para cada Groove como filho dele, esperando que amortecesse só na 
	vertical, já que o Pin Joint seria o filho do Groove. O Pin Joint uniu o Carro as Rodas, fornecendo um elo necessário para manter 
	a roda na posição certa. Infelizmente o resultado não deu certo, pois o que acontecia era que a roda podia subir e descer, mas 
	também havia movimentos de todas direções do Pin Joint. 
</p>

<p align="center">
	<img src="https://github.com/rlcarneiro97/HillClimbGodot/blob/main/readme/papai%20noel2.png" width="400">
</p>

<p align="justify">
	A forma como apliquei é semelhante a colocar um limitador vertical para o Papai Noel preso ao Pin Joint. Portanto, não só o Pin Joint 
	se movia em todas direções, mais o Papai Noel também poderia se mover de cima pra baixo, o que dava a falsa impressão de que era um 
	simples erro a ser corrigido.
</p>
<p align="justify">
	Procurei em vários lugares da internet. Depois de horas buscando algo que clareasse minha mente, achei uma pessoa que tinha solucionado 
	o problema de uma forma aceitável. Achei esse repositório de uma pessoa que resolveu o problema de uma forma muito aproximada da 
	encontrada na Unity (https://github.com/WheelOfPython/Hill_Climb_in_Godot). A partir daí que analisei o projeto e entendi boa parte 
	da solução dele.
</p>

## Solução
<p align="justify">
	A solução tinha a mesma idéia que a minha, porém foi utilizado nós diferentes e com conexões mais complexas. De inicio eu testei com o 
	Damped Spring, mas eu não conseguia fazer a roda ficar no lugar, por isso usei o Pin Joint (e ainda da forma errada). 
	O segredo estava em criar 2 Groove Joints para cada roda, utilizar um Pin Joint rígido para cada roda, e utilizar um objeto intermediário, 
	que faria a ligação entre Carro e Roda, que chamei de “Disco”. 
</p>
<p align="justify">
	Tá, mas porque dois Groove Joints?! Simples! Se você colocar somente um Groove Joint, você até consegue conectar o Carro a Roda, mas o 
	próprio Groove Joint pode rotacionar por alguma força qualquer, inclusive com a própria força gravitacional do jogo. Então, como dar 
	rigidez para o objeto não rotacionar?! Adicionando dois pontos de contato! Um dos pontos sempre compensará a tendência de rotação do 
	outro, fazendo com que a roda fique no lugar. 
</p>
<p align="justify">
	Para que a roda fique no lugar, é preciso entender como colocar os Groove Joints na Cena. Dois deles ficarão para roda da frente, e 
	dois para a roda de trás. O que eu quero é criar um Groove Joint grande a partir de dois menores, onde o começo de um está no fim do 
	outro. Com as propriedades especificas desse nó, é preciso especificar o “Length” com tamanho 25 e o “Initial Offset” 20. Lógico que 
	não é uma regra e você pode encontrar medidas que se ajustem ao seu problema, mas é preciso ter em mente que é preciso sempre conectar 
	os dois como uma “fila”.
</p>
<p align="justify">
	Sendo sincero, ainda é meio nebuloso para mim o comportamento do Groove Joint, porque dependendo do que você altera nas propriedades, 
	pode mudar completamente o comportamento do nó. O que eu sei é que essa estrutura funciona muito bem para delimitar o curso da suspensão. 
</p>
<p align="justify">
	Alem disso, é preciso colocar o “Bias” no máximo (0.9). Porque? Bom, como o Carro, o Disco e a Roda são objetos interagindo com o 
	ambiente em alta velocidade, pode ocorrer deles receberem forças que os empurrem para direções opostas, então é preciso aumentar 
	o Bias pra o objeto acompanhar o movimento de forma correta. Isso faz com que a roda volte mais rápido para o local de onde deve estar. 
	Por fim, todas as conexões do Groove Joint serão feitas entre o Carro e o “Disco”, e o motivo será explicado abaixo.
</p>
<p align="justify">
	Com as conexões entre Carro e Disco feitas, é preciso colocar agora um nó que permita amortecimento, portanto, é preciso de dois 
	Damped Spring para cada roda. Cada um deles liga o Carro ao Disco correspondente. Perceba que nada é ligado a Roda ainda. As 
	configurações das molas são Length 50, Rest Length 0, Stiffness 40, Damping 1. Isso pode variar dependendo da massa do objeto e 
	da gravidade aplicada.
</p>
<p align="justify">
	Com o amortecimento feito, agora é preciso colocar as Rodas. No meu projeto eu optei por colocar as Rodas na cena do Disco, assim, 
	quando eu chamasse a Cena do Disco no Carro, a Roda já viria junto na posição correta. Entretanto, é possível fazer a Roda na 
	própria Cena do Carro mesmo, de forma separada. Se for feito separado, somente o código do Carro que deve ser alterado, mudando o 
	caminho da Roda.
</p>
<p align="justify">
	Certo, a Roda está na Cena, mas não está conectada ao Carro. Como conectar? Porque o Disco existe mesmo?! Primeiro a resposta do Disco. 
	O Disco existe porque se tudo se conectasse diretamente na Roda, quando aplicássemos um torque a roda, não só a roda ganharia velocidade 
	angular, mas também todo conjunto conectado a ela. E girar a suspensão com a roda não é uma boa idéia, na verdade, a roda nem giraria. 
</p>
<p align="justify">	
	Para resolver esses problema do sistema travado, é preciso de um objeto intermediário, que não bloqueia a aplicação de torque.
	Bom, o único nó que nos dá liberdade de rotacionar algo assim é o Pin Joint. Ele pode ficar rígido como uma tachinha presa num quadro 
	bem no centro, e permitir a rotação do que estiver preso lá. 
</p>
<p align="justify">
	Portanto, colocaremos dois Pin Joints rígidos para cada roda, cada um conectando a Roda ao Disco. E como o Disco está conectado ao Carro, 
	todos objetos estão unidos. Como eu coloquei a Cena da Roda dentro da Cena do Disco, então tive que colocar um Pin Joint na Cena do Disco 
	para que as Rodas não ficassem soltas. Então, quando o Carro chama o Disco, não é necessário retrabalho de unir esses componentes.
</p>