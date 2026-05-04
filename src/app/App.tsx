import { BrowserRouter, Routes, Route, Navigate } from 'react-router';
import { useState } from 'react';
import Welcome from './components/Welcome';
import Login from './components/Login';
import ClienteDashboard from './components/ClienteDashboard';
import ColaboradoraDashboard from './components/ColaboradoraDashboard';
import CriarServico from './components/CriarServico';
import DetalheServico from './components/DetalheServico';
import Avaliacao from './components/Avaliacao';

export default function App() {
  const [user, setUser] = useState<{
    id: string;
    nome: string;
    tipo: 'cliente' | 'colaboradora';
    avaliacaoMedia?: number;
  } | null>(null);

  return (
    <BrowserRouter>
      <div className="size-full bg-gray-50">
        <Routes>
          <Route path="/" element={<Welcome />} />
          <Route path="/login/:tipo" element={<Login onLogin={setUser} />} />
          <Route
            path="/cliente"
            element={user?.tipo === 'cliente' ? <ClienteDashboard user={user} /> : <Navigate to="/" />}
          />
          <Route
            path="/colaboradora"
            element={user?.tipo === 'colaboradora' ? <ColaboradoraDashboard user={user} /> : <Navigate to="/" />}
          />
          <Route path="/criar-servico" element={<CriarServico userId={user?.id || ''} />} />
          <Route path="/servico/:id" element={<DetalheServico userTipo={user?.tipo || 'cliente'} />} />
          <Route path="/avaliar/:id" element={<Avaliacao />} />
        </Routes>
      </div>
    </BrowserRouter>
  );
}
