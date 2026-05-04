import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Plus, X } from 'lucide-react';

interface CriarServicoProps {
  userId: string;
}

export default function CriarServico({ userId }: CriarServicoProps) {
  const navigate = useNavigate();
  const [data, setData] = useState('');
  const [endereco, setEndereco] = useState('');
  const [valor, setValor] = useState('');
  const [tarefas, setTarefas] = useState<string[]>([]);
  const [novaTarefa, setNovaTarefa] = useState('');

  const tarefasPredefinidas = [
    'Limpar banheiro',
    'Lavar louça',
    'Aspirar casa',
    'Passar roupa',
    'Limpar cozinha',
    'Organizar quartos',
  ];

  const adicionarTarefa = (tarefa: string) => {
    if (!tarefas.includes(tarefa)) {
      setTarefas([...tarefas, tarefa]);
    }
  };

  const removerTarefa = (tarefa: string) => {
    setTarefas(tarefas.filter((t) => t !== tarefa));
  };

  const handleCriar = () => {
    // Simulação de criação
    navigate('/cliente');
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white px-6 py-4 shadow-sm flex items-center gap-3">
        <button onClick={() => navigate('/cliente')} className="text-gray-600">
          <ArrowLeft className="w-6 h-6" />
        </button>
        <h1 className="text-xl font-bold">Nova Faxina</h1>
      </div>

      <div className="p-6 space-y-6">
        {/* Data */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Data do serviço
          </label>
          <input
            type="date"
            value={data}
            onChange={(e) => setData(e.target.value)}
            className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        {/* Endereço */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Endereço
          </label>
          <input
            type="text"
            value={endereco}
            onChange={(e) => setEndereco(e.target.value)}
            placeholder="Rua, número, bairro"
            className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        {/* Valor */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Valor oferecido (R$)
          </label>
          <input
            type="number"
            value={valor}
            onChange={(e) => setValor(e.target.value)}
            placeholder="150"
            className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        {/* Tarefas Predefinidas */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Tarefas rápidas
          </label>
          <div className="flex flex-wrap gap-2">
            {tarefasPredefinidas.map((tarefa) => (
              <button
                key={tarefa}
                onClick={() => adicionarTarefa(tarefa)}
                disabled={tarefas.includes(tarefa)}
                className={`px-3 py-2 rounded-full text-sm font-medium transition-colors ${
                  tarefas.includes(tarefa)
                    ? 'bg-blue-100 text-blue-700'
                    : 'bg-gray-100 text-gray-700 active:bg-gray-200'
                }`}
              >
                {tarefas.includes(tarefa) ? '✓ ' : '+ '}
                {tarefa}
              </button>
            ))}
          </div>
        </div>

        {/* Adicionar Tarefa Customizada */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Adicionar tarefa personalizada
          </label>
          <div className="flex gap-2">
            <input
              type="text"
              value={novaTarefa}
              onChange={(e) => setNovaTarefa(e.target.value)}
              placeholder="Ex: Lavar janelas"
              className="flex-1 px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            <button
              onClick={() => {
                if (novaTarefa.trim()) {
                  adicionarTarefa(novaTarefa.trim());
                  setNovaTarefa('');
                }
              }}
              className="bg-blue-600 text-white px-4 rounded-xl active:bg-blue-700"
            >
              <Plus className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Lista de Tarefas Selecionadas */}
        {tarefas.length > 0 && (
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-3">
              Tarefas selecionadas ({tarefas.length})
            </label>
            <div className="bg-white rounded-xl p-4 space-y-2">
              {tarefas.map((tarefa, index) => (
                <div
                  key={index}
                  className="flex items-center justify-between py-2 border-b border-gray-100 last:border-0"
                >
                  <span className="text-gray-900">{tarefa}</span>
                  <button
                    onClick={() => removerTarefa(tarefa)}
                    className="text-red-500 active:text-red-700"
                  >
                    <X className="w-5 h-5" />
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Botão Criar */}
        <button
          onClick={handleCriar}
          disabled={!data || !endereco || !valor || tarefas.length === 0}
          className="w-full bg-blue-600 text-white py-4 rounded-xl font-semibold active:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Criar Serviço
        </button>
      </div>
    </div>
  );
}
