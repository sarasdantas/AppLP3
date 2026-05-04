import { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import { ArrowLeft } from 'lucide-react';

interface LoginProps {
  onLogin: (user: {
    id: string;
    nome: string;
    tipo: 'cliente' | 'colaboradora';
    avaliacaoMedia?: number;
  }) => void;
}

export default function Login({ onLogin }: LoginProps) {
  const navigate = useNavigate();
  const { tipo } = useParams<{ tipo: 'cliente' | 'colaboradora' }>();
  const [nome, setNome] = useState('');
  const [email, setEmail] = useState('');

  const handleLogin = () => {
    if (!nome || !email) return;

    const user = {
      id: Math.random().toString(36).substr(2, 9),
      nome,
      tipo: tipo as 'cliente' | 'colaboradora',
      avaliacaoMedia: tipo === 'colaboradora' ? 4.8 : undefined,
    };

    onLogin(user);
    navigate(`/${tipo}`);
  };

  return (
    <div className="min-h-screen bg-white p-6">
      <button
        onClick={() => navigate('/')}
        className="mb-8 text-gray-600 active:text-gray-900"
      >
        <ArrowLeft className="w-6 h-6" />
      </button>

      <div className="max-w-md mx-auto">
        <h1 className="text-3xl font-bold mb-2">
          {tipo === 'cliente' ? 'Acesso Cliente' : 'Acesso Colaboradora'}
        </h1>
        <p className="text-gray-600 mb-8">
          Entre com seus dados para continuar
        </p>

        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Nome completo
            </label>
            <input
              type="text"
              value={nome}
              onChange={(e) => setNome(e.target.value)}
              className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Seu nome"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              E-mail
            </label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="seu@email.com"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Senha
            </label>
            <input
              type="password"
              className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="••••••••"
            />
          </div>

          <button
            onClick={handleLogin}
            className="w-full bg-blue-600 text-white py-4 rounded-xl font-semibold mt-6 active:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
            disabled={!nome || !email}
          >
            Entrar
          </button>

          <p className="text-center text-sm text-gray-600 mt-4">
            Não tem conta?{' '}
            <span className="text-blue-600 font-semibold">Cadastre-se</span>
          </p>
        </div>
      </div>
    </div>
  );
}
