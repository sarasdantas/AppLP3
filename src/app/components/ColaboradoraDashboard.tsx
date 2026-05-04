import { useState } from 'react';
import { useNavigate } from 'react-router';
import { MapPin, DollarSign, Calendar, Star } from 'lucide-react';

interface User {
  id: string;
  nome: string;
  tipo: 'cliente' | 'colaboradora';
  avaliacaoMedia?: number;
}

interface ColaboradoraDashboardProps {
  user: User;
}

const oportunidadesMock = [
  {
    id: '1',
    cliente: 'João Pedro',
    data: '2026-05-05',
    endereco: 'Rua das Flores, 123 - Centro',
    valor: 150,
    tarefas: 5,
    distancia: '2.3 km',
  },
  {
    id: '4',
    cliente: 'Fernanda Costa',
    data: '2026-05-06',
    endereco: 'Av. Paulista, 1000 - Bela Vista',
    valor: 220,
    tarefas: 8,
    distancia: '5.1 km',
  },
  {
    id: '5',
    cliente: 'Carlos Mendes',
    data: '2026-05-07',
    endereco: 'Rua Augusta, 550 - Consolação',
    valor: 180,
    tarefas: 6,
    distancia: '3.8 km',
  },
  {
    id: '6',
    cliente: 'Patricia Lima',
    data: '2026-05-08',
    endereco: 'Rua Haddock Lobo, 234 - Jardins',
    valor: 200,
    tarefas: 7,
    distancia: '4.2 km',
  },
];

export default function ColaboradoraDashboard({ user }: ColaboradoraDashboardProps) {
  const navigate = useNavigate();
  const [filter, setFilter] = useState<'todos' | 'perto' | 'melhor-valor'>('todos');

  const oportunidadesFiltradas = [...oportunidadesMock].sort((a, b) => {
    if (filter === 'perto') return parseFloat(a.distancia) - parseFloat(b.distancia);
    if (filter === 'melhor-valor') return b.valor - a.valor;
    return 0;
  });

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header com Perfil */}
      <div className="bg-gradient-to-r from-purple-600 to-blue-600 text-white px-6 py-6">
        <div className="flex items-center gap-3 mb-4">
          <div className="w-14 h-14 bg-white rounded-full flex items-center justify-center text-purple-600 font-bold text-xl">
            {user.nome.charAt(0)}
          </div>
          <div>
            <h2 className="font-bold text-lg">{user.nome}</h2>
            <div className="flex items-center gap-1">
              <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
              <span className="font-medium">{user.avaliacaoMedia}</span>
              <span className="text-purple-200 text-sm ml-1">(48 avaliações)</span>
            </div>
          </div>
        </div>
        <div className="bg-white/20 backdrop-blur-sm rounded-xl p-3 grid grid-cols-3 gap-3 text-center">
          <div>
            <p className="text-2xl font-bold">127</p>
            <p className="text-xs text-purple-100">Serviços</p>
          </div>
          <div>
            <p className="text-2xl font-bold">98%</p>
            <p className="text-xs text-purple-100">Aprovação</p>
          </div>
          <div>
            <p className="text-2xl font-bold">R$ 8,4k</p>
            <p className="text-xs text-purple-100">Este mês</p>
          </div>
        </div>
      </div>

      {/* Filtros */}
      <div className="bg-white px-6 py-4 shadow-sm">
        <h3 className="font-semibold mb-3">Oportunidades disponíveis</h3>
        <div className="flex gap-2 overflow-x-auto">
          {(['todos', 'perto', 'melhor-valor'] as const).map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors ${
                filter === f
                  ? 'bg-purple-600 text-white'
                  : 'bg-gray-100 text-gray-700'
              }`}
            >
              {f === 'todos' && 'Todos'}
              {f === 'perto' && 'Mais perto'}
              {f === 'melhor-valor' && 'Melhor valor'}
            </button>
          ))}
        </div>
      </div>

      {/* Lista de Oportunidades */}
      <div className="p-6 space-y-3">
        {oportunidadesFiltradas.map((oportunidade) => (
          <div
            key={oportunidade.id}
            className="bg-white rounded-2xl p-4 shadow-sm"
          >
            <div className="flex justify-between items-start mb-3">
              <div>
                <p className="font-semibold text-gray-900">{oportunidade.cliente}</p>
                <div className="flex items-center gap-1 text-sm text-gray-600 mt-1">
                  <Calendar className="w-4 h-4" />
                  {oportunidade.data}
                </div>
              </div>
              <div className="text-right">
                <p className="text-2xl font-bold text-green-600">R$ {oportunidade.valor}</p>
                <p className="text-xs text-gray-500">{oportunidade.tarefas} tarefas</p>
              </div>
            </div>

            <div className="flex items-start gap-2 text-sm text-gray-600 mb-4">
              <MapPin className="w-4 h-4 mt-0.5 flex-shrink-0" />
              <span>{oportunidade.endereco}</span>
            </div>

            <div className="flex gap-2">
              <button
                onClick={() => navigate(`/servico/${oportunidade.id}`)}
                className="flex-1 bg-purple-600 text-white py-3 rounded-xl font-medium active:bg-purple-700"
              >
                Aceitar
              </button>
              <button className="px-4 border-2 border-purple-600 text-purple-600 rounded-xl font-medium active:bg-purple-50">
                Detalhes
              </button>
            </div>

            <div className="mt-3 pt-3 border-t border-gray-100 flex items-center justify-between text-sm">
              <span className="text-gray-600 flex items-center gap-1">
                <MapPin className="w-4 h-4" />
                {oportunidade.distancia} de você
              </span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
