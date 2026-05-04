import { useNavigate } from 'react-router';
import { Sparkles, UserCheck } from 'lucide-react';

export default function Welcome() {
  const navigate = useNavigate();

  return (
    <div className="h-screen flex flex-col bg-gradient-to-br from-blue-500 to-purple-600 text-white p-6">
      <div className="flex-1 flex flex-col justify-center items-center text-center">
        <Sparkles className="w-20 h-20 mb-4" />
        <h1 className="text-4xl font-bold mb-2">Casa Limpa</h1>
        <p className="text-blue-100 text-lg">
          Conectando você aos melhores serviços de limpeza
        </p>
      </div>

      <div className="space-y-3">
        <button
          onClick={() => navigate('/login/cliente')}
          className="w-full bg-white text-blue-600 py-4 rounded-2xl font-semibold shadow-lg active:scale-95 transition-transform"
        >
          Sou Cliente
        </button>
        <button
          onClick={() => navigate('/login/colaboradora')}
          className="w-full bg-blue-700 text-white py-4 rounded-2xl font-semibold shadow-lg active:scale-95 transition-transform flex items-center justify-center gap-2"
        >
          <UserCheck className="w-5 h-5" />
          Sou Colaboradora
        </button>
      </div>

      <p className="text-center text-blue-100 text-sm mt-6">
        Projeto Acadêmico - Casa Limpa © 2026
      </p>
    </div>
  );
}
