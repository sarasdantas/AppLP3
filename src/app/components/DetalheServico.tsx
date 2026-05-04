import { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import { ArrowLeft, MapPin, Calendar, User, CheckCircle2 } from 'lucide-react';

interface DetalheServicoProps {
  userTipo: 'cliente' | 'colaboradora';
}

export default function DetalheServico({ userTipo }: DetalheServicoProps) {
  const navigate = useNavigate();
  const { id } = useParams();

  const [tarefas, setTarefas] = useState([
    { id: 1, nome: 'Limpar banheiro', concluida: true },
    { id: 2, nome: 'Lavar louça', concluida: true },
    { id: 3, nome: 'Aspirar casa', concluida: true },
    { id: 4, nome: 'Passar roupa', concluida: false },
    { id: 5, nome: 'Limpar cozinha', concluida: false },
  ]);

  const toggleTarefa = (tarefaId: number) => {
    if (userTipo === 'colaboradora') {
      setTarefas(
        tarefas.map((t) =>
          t.id === tarefaId ? { ...t, concluida: !t.concluida } : t
        )
      );
    }
  };

  const progresso = Math.round(
    (tarefas.filter((t) => t.concluida).length / tarefas.length) * 100
  );

  const servico = {
    cliente: 'João Pedro',
    colaboradora: 'Maria Silva',
    data: '2026-04-29',
    endereco: 'Av. Principal, 456 - Centro',
    valor: 200,
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white px-6 py-4 shadow-sm flex items-center gap-3">
        <button
          onClick={() => navigate(userTipo === 'cliente' ? '/cliente' : '/colaboradora')}
          className="text-gray-600"
        >
          <ArrowLeft className="w-6 h-6" />
        </button>
        <h1 className="text-xl font-bold">Detalhes da Faxina</h1>
      </div>

      {/* Informações do Serviço */}
      <div className="bg-white m-6 rounded-2xl p-5 shadow-sm space-y-4">
        <div className="flex items-start gap-3">
          <MapPin className="w-5 h-5 text-blue-600 mt-1" />
          <div>
            <p className="font-semibold">Endereço</p>
            <p className="text-sm text-gray-600">{servico.endereco}</p>
          </div>
        </div>

        <div className="flex items-start gap-3">
          <Calendar className="w-5 h-5 text-blue-600 mt-1" />
          <div>
            <p className="font-semibold">Data</p>
            <p className="text-sm text-gray-600">{servico.data}</p>
          </div>
        </div>

        <div className="flex items-start gap-3">
          <User className="w-5 h-5 text-blue-600 mt-1" />
          <div>
            <p className="font-semibold">
              {userTipo === 'cliente' ? 'Colaboradora' : 'Cliente'}
            </p>
            <p className="text-sm text-gray-600">
              {userTipo === 'cliente' ? servico.colaboradora : servico.cliente}
            </p>
          </div>
        </div>

        <div className="pt-4 border-t border-gray-100">
          <div className="flex justify-between items-center">
            <span className="font-semibold">Valor</span>
            <span className="text-2xl font-bold text-green-600">
              R$ {servico.valor}
            </span>
          </div>
        </div>
      </div>

      {/* Progresso */}
      <div className="mx-6 mb-6 bg-white rounded-2xl p-5 shadow-sm">
        <div className="flex justify-between items-center mb-3">
          <h3 className="font-semibold">Progresso</h3>
          <span className="text-2xl font-bold text-blue-600">{progresso}%</span>
        </div>
        <div className="w-full bg-gray-200 rounded-full h-3">
          <div
            className="bg-blue-600 h-3 rounded-full transition-all duration-300"
            style={{ width: `${progresso}%` }}
          />
        </div>
        <p className="text-sm text-gray-600 mt-2">
          {tarefas.filter((t) => t.concluida).length} de {tarefas.length} tarefas concluídas
        </p>
      </div>

      {/* Lista de Tarefas (Checklist) */}
      <div className="mx-6 mb-6">
        <h3 className="font-semibold mb-3 text-gray-900">Lista de Tarefas</h3>
        <div className="bg-white rounded-2xl shadow-sm overflow-hidden">
          {tarefas.map((tarefa) => (
            <div
              key={tarefa.id}
              onClick={() => toggleTarefa(tarefa.id)}
              className={`flex items-center gap-4 p-4 border-b border-gray-100 last:border-0 transition-colors ${
                userTipo === 'colaboradora' ? 'active:bg-gray-50' : ''
              }`}
            >
              <div
                className={`w-6 h-6 rounded-full border-2 flex items-center justify-center flex-shrink-0 transition-all ${
                  tarefa.concluida
                    ? 'bg-green-500 border-green-500'
                    : 'border-gray-300'
                }`}
              >
                {tarefa.concluida && (
                  <CheckCircle2 className="w-4 h-4 text-white" />
                )}
              </div>
              <span
                className={`flex-1 ${
                  tarefa.concluida
                    ? 'line-through text-gray-400'
                    : 'text-gray-900'
                }`}
              >
                {tarefa.nome}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Botão de Ação */}
      {userTipo === 'colaboradora' && progresso === 100 && (
        <div className="px-6 pb-6">
          <button className="w-full bg-green-600 text-white py-4 rounded-xl font-semibold active:bg-green-700">
            Finalizar Serviço
          </button>
        </div>
      )}
    </div>
  );
}
