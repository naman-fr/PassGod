import React, { useState } from 'react';
import api from '../../api/api';
import QRCode from 'qrcode.react';

interface ShareModalProps {
  open: boolean;
  onClose: () => void;
  encryptedData: string;
}

const ShareModal: React.FC<ShareModalProps> = ({ open, onClose, encryptedData }) => {
  const [expires, setExpires] = useState(60);
  const [shareLink, setShareLink] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleShare = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await api.post('/share/create', {
        encrypted_data: encryptedData,
        expires_in_minutes: expires,
      });
      const url = `${window.location.origin}/share/${res.data.token}`;
      setShareLink(url);
    } catch (e: any) {
      setError('Failed to create share link.');
    } finally {
      setLoading(false);
    }
  };

  if (!open) return null;

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-8 w-full max-w-md shadow-lg relative">
        <button className="absolute top-2 right-2 text-gray-400 hover:text-black" onClick={onClose}>&times;</button>
        <h2 className="text-2xl font-bold mb-4">Secure Share</h2>
        <label className="block mb-2 font-semibold">Expires in (minutes):</label>
        <input
          type="number"
          min={1}
          max={1440}
          value={expires}
          onChange={e => setExpires(Number(e.target.value))}
          className="w-full border rounded px-3 py-2 mb-4"
        />
        <button
          className="w-full bg-blue-600 text-white py-2 rounded font-bold hover:bg-blue-700 transition mb-4"
          onClick={handleShare}
          disabled={loading}
        >
          {loading ? 'Generating...' : 'Generate Share Link'}
        </button>
        {error && <div className="text-red-600 mb-2">{error}</div>}
        {shareLink && (
          <div className="mt-4 text-center">
            <div className="mb-2">Share this link or QR code:</div>
            <input
              type="text"
              value={shareLink}
              readOnly
              className="w-full border rounded px-2 py-1 mb-2 text-center"
              onClick={e => (e.target as HTMLInputElement).select()}
            />
            <QRCode value={shareLink} size={128} className="mx-auto" />
          </div>
        )}
      </div>
    </div>
  );
};

export default ShareModal; 