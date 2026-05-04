import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Plus, Clock, CheckCircle, Star } from 'lucide-react';

interface User {
  id: string;
  nome: string;
  tipo: 'cliente' | 'colaboradora';
}

interface ClienteDashboardProps {
  user: User;
}

const servicosMock = [
  {
    id: '1',
    data: '2026-05-05',
    endereco: 'Rua das Flores, 123',
    valor: 150,
    status: 'aberto',
    tarefas: 5,
    colaboradora: null,
  },
  {
    id: '2',
    data: '2026-04-29',
    endereco: 'Av. Principal, 456',
    valor: 200,
    status: 'em andamento',
    tarefas: 8,
    colaboradora: 'Maria Silva',
  },
  {
    id: '3',
    data: '2026-04-20',
    endereco: 'Rua do Comércio, 789',
    valor: 180,
    status: 'finalizado',
    tarefas: 6,
    colaboradora: 'Ana Santos',
  },
];

export default function ClienteDashboard({ user }: ClienteDashboardProps) {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<'todos' | 'abertos' | 'finalizados'>('todos');

  const servicosFiltrados = servicosMock.filter((s) => {
    if (activeTab === 'abertos') return s.status === 'aberto' || s.status === 'em andamento';
    if (activeTab === 'finalizados') return s.status === 'finalizado';
    return true;
  });

  const getStatusColor = (status: string) => {
    if (status === 'aberto') return 'bg-yellow-100 text-yellow-700';
    if (status === 'em andamento') return 'bg-blue-100 text-blue-700';
    return 'bg-green-100 text-green-700';
  };

  const getStatusIcon = (status: string) => {
    if (status === 'aberto') return <Clock className="w-4 h-4" />;
    if (status === 'em andamento') return <Clock className="w-4 h-4" />;
    return <CheckCircle className="w-4 h-4" />;
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white px-6 py-4 shadow-sm">
        <h2 className="text-xl font-bold">Olá, {user.nome}! 👋</h2>
        <p className="text-sm text-gray-600">Gerencie suas faxinas</p>
      </div>

      {/* Tabs */}
      <div className="bg-white px-6 py-3 flex gap-2 border-b">
        {(['todos', 'abertos', 'finalizados'] as const).map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              activeTab === tab
                ? 'bg-blue-600 text-white'
                : 'bg-gray-100 text-gray-700'
            }`}
          >
            {tab.charAt(0).toUpperCase() + tab.slice(1)}
          </button>
        ))}
      </div>

      {/* Lista de Serviços */}
      <div className="p-6 space-y-3">
        {servicosFiltrados.map((servico) => (
          <div
            key={servico.id}
            onClick={() => navigate(`/servico/${servico.id}`)}
            className="bg-white rounded-2xl p-4 shadow-sm active:shadow-md transition-shadow"
          >
            <div className="flex justify-between items-start mb-3">
              <div>
                <p className="font-semibold text-gray-900">{servico.endereco}</p>
                <p className="text-sm text-gray-600">{servico.data}</p>
              </div>
              <span className={`px-3 py-1 rounded-full text-xs font-medium flex items-center gap-1 ${getStatusColor(servico.status)}`}>
                {getStatusIcon(servico.status)}
                {servico.status}
              </span>
            </div>

            {servico.colaboradora && (
              <p className="text-sm text-gray-600 mb-2">
                Colaboradora: <span className="font-medium">{servico.colaboradora}</span>
              </p>
            )}

            <div className="flex justify-between items-center pt-2 border-t border-gray-100">
              <span className="text-sm text-gray-600">{servico.tarefas} tarefas</span>
              <span className="font-bold text-blue-600">R$ {servico.valor}</span>
            </div>

            {servico.status === 'finalizado' && (
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  navigate(`/avaliar/${servico.id}`);
                }}
                className="w-full mt-3 bg-yellow-400 text-gray-900 py-2 rounded-lg font-medium flex items-center justify-center gap-2 active:bg-yellow-500"
              >
                <Star className="w-4 h-4" />
                Avaliar serviço
              </button>
            )}
          </div>
        ))}
      </div>

      {/* Botão Flutuante */}
      <button
        onClick={() => navigate('/criar-servico')}
        className="fixed bottom-6 right-6 bg-blue-600 text-white w-16 h-16 rounded-full shadow-lg flex items-center justify-center active:scale-95 transition-transform"
      >
        <Plus className="w-8 h-8" />
      </button>
    </div>
  );
}
