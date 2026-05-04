import { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import { ArrowLeft, Star } from 'lucide-react';

export default function Avaliacao() {
  const navigate = useNavigate();
  const { id } = useParams();
  const [nota, setNota] = useState(0);
  const [comentario, setComentario] = useState('');

  const handleEnviar = () => {
    // Simulação de envio
    navigate('/cliente');
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white px-6 py-4 shadow-sm flex items-center gap-3">
        <button onClick={() => navigate('/cliente')} className="text-gray-600">
          <ArrowLeft className="w-6 h-6" />
        </button>
        <h1 className="text-xl font-bold">Avaliar Serviço</h1>
      </div>

      <div className="p-6">
        {/* Colaboradora */}
        <div className="bg-white rounded-2xl p-5 shadow-sm text-center mb-6">
          <div className="w-20 h-20 bg-purple-100 rounded-full mx-auto mb-3 flex items-center justify-center text-purple-600 text-3xl font-bold">
            M
          </div>
          <h3 className="font-semibold text-lg">Maria Silva</h3>
          <p className="text-sm text-gray-600">Colaboradora</p>
        </div>

        {/* Estrelas */}
        <div className="bg-white rounded-2xl p-6 shadow-sm mb-6">
          <h3 className="font-semibold mb-4 text-center">Como foi o serviço?</h3>
          <div className="flex justify-center gap-3 mb-2">
            {[1, 2, 3, 4, 5].map((star) => (
              <button
                key={star}
                onClick={() => setNota(star)}
                className="transition-transform active:scale-110"
              >
                <Star
                  className={`w-12 h-12 ${
                    star <= nota
                      ? 'fill-yellow-400 text-yellow-400'
                      : 'text-gray-300'
                  }`}
                />
              </button>
            ))}
          </div>
          <p className="text-center text-sm text-gray-600 mt-3">
            {nota === 0 && 'Selecione uma nota'}
            {nota === 1 && 'Muito ruim'}
            {nota === 2 && 'Ruim'}
            {nota === 3 && 'Regular'}
            {nota === 4 && 'Bom'}
            {nota === 5 && 'Excelente!'}
          </p>
        </div>

        {/* Comentário */}
        <div className="bg-white rounded-2xl p-5 shadow-sm mb-6">
          <label className="block font-semibold mb-3">
            Deixe um comentário (opcional)
          </label>
          <textarea
            value={comentario}
            onChange={(e) => setComentario(e.target.value)}
            placeholder="Conte como foi sua experiência..."
            className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 min-h-[120px] resize-none"
          />
        </div>

        {/* Botão Enviar */}
        <button
          onClick={handleEnviar}
          disabled={nota === 0}
          className="w-full bg-blue-600 text-white py-4 rounded-xl font-semibold active:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Enviar Avaliação
        </button>
      </div>
    </div>
  );
}
